using UnityEngine;

[RequireComponent(typeof(PolygonCollider2D),typeof(CompositeCollider2D), typeof(LineRenderer))]
public class Outline : MonoBehaviour
{
    [Header("Outline properties")]
    [SerializeField] private float _stroke = 0.1f;
    [SerializeField] private Color _color = Color.black;

    [Header("Outline Dependencies")]
    [SerializeField] private Rigidbody2D _rb;
    [SerializeField] private PolygonCollider2D _clPolygon;
    [SerializeField] private CompositeCollider2D _clComposite;
    [SerializeField] private LineRenderer _outline;

    private void Reset()
    {
        _rb = GetComponent<Rigidbody2D>();
        _clPolygon = GetComponent<PolygonCollider2D>();
        _clComposite = GetComponent<CompositeCollider2D>();
        _outline = GetComponent<LineRenderer>();

        _rb.isKinematic = true;
        _clComposite.geometryType = CompositeCollider2D.GeometryType.Outlines;
        _clPolygon.usedByComposite = true;

        _outline.loop = true;
        _outline.numCornerVertices = 10;
    }

    private void Start()
    {
        SetupOutline();
    }

    private void SetupOutline()
    {
        _outline.startWidth = _outline.endWidth = _stroke;
        _outline.startColor = _outline.endColor = _color;

        _outline.positionCount = _clPolygon.points.Length;

        for (int i = 0; i < _clPolygon.points.Length; i++)
        {
            _outline.SetPosition(i, _clPolygon.points[i]);
        }
    }
}
