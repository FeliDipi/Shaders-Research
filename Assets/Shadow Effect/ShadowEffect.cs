using UnityEngine;
using UnityEngine.UI;

public class ShadowEffect : MonoBehaviour
{
    [SerializeField] private RectTransform _base;

    [Header("Shadow Effect Properties")]

    [SerializeField] private Vector3 _offset = Vector2.one;
    [SerializeField] private Material _customMaterial;

    private void Start()
    {
        if (_base == null)
        {
            Debug.LogError("The _base RectTransform is not assigned in the Inspector.");
            return;
        }

        CreateShadow();
    }

    private void CreateShadow()
    {
        if (_base == null)
        {
            Debug.LogError("The _base RectTransform is not assigned.");
            return;
        }

        GameObject shadow = Instantiate(_base.gameObject, _base.parent);
        shadow.transform.position += _offset;

        RectTransform content = new GameObject($"{_base.name}_CONTENT").AddComponent<RectTransform>();

        if (content == null)
        {
            Debug.LogError("Failed to create the content RectTransform.");
            return;
        }

        content.SetParent(_base.parent);
        content.position = _base.position;

        shadow.transform.SetParent(content);
        _base.SetParent(content);

        SetupMaterial(shadow);
    }

    private void SetupMaterial(GameObject element)
    {
        if(!element.GetComponent<Mask>() && element.TryGetComponent(out Image comp))
        {
            comp.material = _customMaterial;
        }

        foreach(Transform child in element.transform)
        {
            SetupMaterial(child.gameObject);
        }
    }
}
