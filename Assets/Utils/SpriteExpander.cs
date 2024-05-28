using UnityEngine;

[RequireComponent(typeof(SpriteRenderer))]
public class SpriteExpander : MonoBehaviour
{
    [SerializeField] private float _expandFactor = 2.0f;
    private SpriteRenderer _spr;

    private void Awake()
    {
        _spr = GetComponent<SpriteRenderer>();
    }

    void Start()
    {
        Sprite originalSprite = _spr.sprite;
        Sprite expandedSprite = ExpandSpriteGeometry(originalSprite, _expandFactor);

        _spr.sprite = expandedSprite;
    }

    Sprite ExpandSpriteGeometry(Sprite originalSprite, float factor)
    {
        // Get original dimensions
        Rect originalRect = originalSprite.rect;
        float width = originalRect.width;
        float height = originalRect.height;

        // Calculate new dimensions
        float newWidth = width * factor;
        float newHeight = height * factor;

        // Create a new Texture with new dimensions
        Texture2D newTexture = new Texture2D((int)newWidth, (int)newHeight, TextureFormat.RGBA32, false);

        // Disable any filter
        newTexture.filterMode = FilterMode.Point;
        newTexture.wrapMode = TextureWrapMode.Clamp;

        // Set padding with alpha pixels
        Color[] transparentPixels = new Color[(int)newWidth * (int)newHeight];
        for (int i = 0; i < transparentPixels.Length; i++)
        {
            transparentPixels[i] = Color.clear;
        }
        newTexture.SetPixels(transparentPixels);

        // Add original texture to the center of new texture
        Color[] originalPixels = originalSprite.texture.GetPixels(
            (int)originalRect.x,
            (int)originalRect.y,
            (int)originalRect.width,
            (int)originalRect.height
        );

        int startX = (int)((newWidth - originalRect.width) / 2);
        int startY = (int)((newHeight - originalRect.height) / 2);

        newTexture.SetPixels(startX, startY, (int)originalRect.width, (int)originalRect.height, originalPixels);
        newTexture.Apply();

        // Create new geometry
        var sv = new[]
        {
            new Vector2(0, 0),
            new Vector2(newWidth, 0),
            new Vector2(newWidth, newHeight),
            new Vector2(0, newHeight)
        };
        var indices = new ushort[] { 0, 1, 2, 2, 3, 0 };

        // Create new expand sprite follow the data generated
        Sprite expandedSprite = Sprite.Create(
            newTexture,
            new Rect(0, 0, newWidth, newHeight),
            new Vector2(0.5f, 0.5f),
            originalSprite.pixelsPerUnit
        );

        // Set geometry
        expandedSprite.OverrideGeometry(sv, indices);

        return expandedSprite;
    }
}
