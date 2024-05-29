using UnityEngine;
using UnityEngine.UI;

public class UIMaskMaker : SpriteMaskMaker
{
    [Header("UI Properties")]
    [SerializeField] private Image _referenceUI;
    [SerializeField] private Image _maskUI;

    protected new void Awake()
    {
        base.Awake();

        SetupSpriteRenderers();
    }

    private void SetupSpriteRenderers()
    {
        _reference = new GameObject("TEMP_spr").AddComponent<SpriteRenderer>();
        _mask = new GameObject("TEMP_mask_spr").AddComponent<SpriteRenderer>();

        _reference.sprite = _referenceUI.sprite;
        _mask.sprite = _maskUI.sprite;
    }

    protected override void SetupNewSprite(Sprite newSprite)
    {
        _reference.enabled = _mask.enabled = false;

        _referenceUI.sprite = newSprite;
        _referenceUI.material = _customMaterial;
    }
}
