using UnityEngine;

public class Outline : MonoBehaviour
{
    [SerializeField] private PolygonCollider2D _reference;
    [SerializeField] private LineRenderer _outline;

    private void Start()
    {
        SetupOutline();
    }

    private void SetupOutline()
    {
        _outline.positionCount = _reference.points.Length;

        for (int i = 0; i < _reference.points.Length; i++)
        {
            _outline.SetPosition(i, _reference.points[i]);
        }
    }
}
