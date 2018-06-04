using UnityEngine;

[RequireComponent(typeof(Shape2DExtrudeSegment))]
[RequireComponent(typeof(MeshRenderer))]
[ExecuteInEditMode]
public class PashTroughCurve : MonoBehaviour {

	private Shape2DExtrudeSegment _segment;
	private MeshRenderer _renderer;

	[Range(0, 1)]
	public float range = 0;
	[Range(0, 10)]
	public float radius = 0;
	[Range(0, 5)]
	public float chamf = 1;

	private void Awake() {
		_segment = GetComponent<Shape2DExtrudeSegment>();
		_renderer = GetComponent<MeshRenderer>();
	}

	void Update () {
		Vector3 position = _segment.InterpolatePosition(range);
		Vector3 tangent = _segment.InterpolateTangent(range);
		_renderer.sharedMaterial.SetVector("_ExpansionCenter", position);
		_renderer.sharedMaterial.SetVector("_ExpansionNormal", tangent);
		_renderer.sharedMaterial.SetFloat("_ExpansionRadius", radius);
		_renderer.sharedMaterial.SetFloat("_ExpansionChamf", chamf);
	}
}