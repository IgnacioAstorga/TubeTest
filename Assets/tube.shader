Shader "Custom/Tube Expansion" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_TessellationCount("Tessellation", Range(1,16)) = 1
		[MaterialToggle]_SimpleTessellation("Simple Tessellation", Float) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM

		#pragma surface surf Standard addshadow fullforwardshadows vertex:vert tessellate:tess

		sampler2D _MainTex;
		fixed4 _Color;
		float _TessellationCount;
		bool _SimpleTessellation;

		struct Input {
			float2 uv_MainTex;
		};

		UNITY_INSTANCING_CBUFFER_START(Props)
			float _ExpansionRadius;
			float3 _ExpansionCenter;
			float3 _ExpansionNormal;
			float _ExpansionChamf;
		UNITY_INSTANCING_CBUFFER_END

		float3 getDirectionToVertex(float3 pos) {
			float3 direction = pos - _ExpansionCenter;
			float3 chamfedDirection = (_ExpansionChamf - 1) * dot(direction, _ExpansionNormal) * _ExpansionNormal;
			return direction + chamfedDirection;
		}

		bool triangleIntersectSphereTest(float3 A, float3 B, float3 C, float rr) {
			float3 V = cross(B - A, C - A);
			float d = dot(A, V);
			float e = dot(V, V);
			bool sep1 = d * d > rr * e;
			float aa = dot(A, A);
			float ab = dot(A, B);
			float ac = dot(A, C);
			float bb = dot(B, B);
			float bc = dot(B, C);
			float cc = dot(C, C);
			bool sep2 = (aa > rr) & (ab > aa) & (ac > aa);
			bool sep3 = (bb > rr) & (ab > bb) & (bc > bb);
			bool sep4 = (cc > rr) & (ac > cc) & (bc > cc);
			float3 AB = B - A;
			float3 BC = C - B;
			float3 CA = A - C;
			float d1 = ab - aa;
			float d2 = bc - bb;
			float d3 = ac - cc;
			float e1 = dot(AB, AB);
			float e2 = dot(BC, BC);
			float e3 = dot(CA, CA);
			float3 Q1 = A * e1 - d1 * AB;
			float3 Q2 = B * e2 - d2 * BC;
			float3 Q3 = C * e3 - d3 * CA;
			float3 QC = C * e1 - Q1;
			float3 QA = A * e2 - Q2;
			float3 QB = B * e3 - Q3;
			bool sep5 = (dot(Q1, Q1) > rr * e1 * e1) & (dot(Q1, QC) > 0);
			bool sep6 = (dot(Q2, Q2) > rr * e2 * e2) & (dot(Q2, QA) > 0);
			bool sep7 = (dot(Q3, Q3) > rr * e3 * e3) & (dot(Q3, QB) > 0);
			return !(sep1 | sep2 | sep3 | sep4 | sep5 | sep6 | sep7);
		}

		float4 tess(appdata_full v1, appdata_full v2, appdata_full v3) {
			float3 A = getDirectionToVertex(v1.vertex.xyz);
			float3 B = getDirectionToVertex(v2.vertex.xyz);
			float3 C = getDirectionToVertex(v3.vertex.xyz);
			float rr = _ExpansionRadius * _ExpansionRadius;

			if (_SimpleTessellation) {
				if (dot(A, A) <= rr || dot(B, B) <= rr || dot(C, C) <= rr)
					return _TessellationCount;
				else
					return 1;
			}
			else {
				if (triangleIntersectSphereTest(A, B, C, rr))
					return 1;
				else
					return _TessellationCount;
			}
		}

		void vert(inout appdata_full v) {
			float3 direction = getDirectionToVertex(v.vertex.xyz);
			float sqrDistance = dot(direction, direction);
			if (sqrDistance <= _ExpansionRadius * _ExpansionRadius) {				
				float norm = sqrt(sqrDistance);
				float3 normalizedDirection = direction / norm;
				float3 expansion = (_ExpansionRadius - norm) * normalizedDirection;
				v.vertex.xyz += expansion;

				float chamfFactor = abs(dot(normalizedDirection, _ExpansionNormal));
				chamfFactor *= chamfFactor * (3 - 2 * chamfFactor);
				float3 lerped = normalize(chamfFactor * v.normal + (1 - chamfFactor) * normalizedDirection);
				v.normal = lerped;
			}
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
