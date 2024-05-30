using UnityEngine;
using UnityEngine.UI;

public class SpriteMaskMaker : MonoBehaviour
{
    [Header("Base Properties")]

    [SerializeField] protected SpriteRenderer _reference;
    [SerializeField] protected SpriteRenderer _mask;
    [SerializeField] protected Material _customMaterial;

    protected Camera _camera;

    private float _originalSize;

    protected void Awake()
    {
        _camera = Camera.main;
        _originalSize = _camera.orthographicSize;
    }

    private void Start()
    {
        CreateMaskedSprite();
    }

    private void CreateMaskedSprite()
    {
        _mask.enabled = false;

        int width = _reference.sprite.texture.width;
        int height = _reference.sprite.texture.height;
        RenderTexture renderTexture = new RenderTexture(width, height, 24);
        _camera.targetTexture = renderTexture;

        _camera.transform.position = new Vector3(_reference.transform.position.x, _reference.transform.position.y, _camera.transform.position.z);
        _camera.orthographicSize = _reference.bounds.size.y / 2;

        _camera.Render();

        Texture2D capturedTexture = new Texture2D(width, height, TextureFormat.ARGB32, false);
        RenderTexture.active = renderTexture;
        capturedTexture.ReadPixels(new Rect(0, 0, width, height), 0, 0);
        capturedTexture.Apply();

        _camera.targetTexture = null;
        _camera.orthographicSize = _originalSize;
        RenderTexture.active = null;
        Destroy(renderTexture);

        _mask.enabled = true;

        Vector3 maskPosition = _mask.transform.position;
        Vector2Int maskTexturePosition = WorldToTextureCoordinates(maskPosition, _camera, capturedTexture.width, capturedTexture.height);

        Texture2D newTexture = new Texture2D(_mask.sprite.texture.width, _mask.sprite.texture.height, TextureFormat.ARGB32, false);

        newTexture.filterMode = FilterMode.Point;
        newTexture.wrapMode = TextureWrapMode.Clamp;

        Color[] maskPixels = _mask.sprite.texture.GetPixels();
        Color[] referencePixels = capturedTexture.GetPixels();

        for (int y = 0; y < newTexture.height; y++)
        {
            for (int x = 0; x < newTexture.width; x++)
            {
                int maskIndex = y * newTexture.width + x;
                int bgX = x + maskTexturePosition.x - _mask.sprite.texture.width / 2;
                int bgY = y + maskTexturePosition.y - _mask.sprite.texture.height / 2;

                if (bgX >= 0 && bgX < capturedTexture.width && bgY >= 0 && bgY < capturedTexture.height)
                {
                    int refIndex = bgY * capturedTexture.width + bgX;
                    if (maskPixels[maskIndex].a > 0.5f)
                    {
                        newTexture.SetPixel(x, y, referencePixels[refIndex]);
                    }
                    else
                    {
                        newTexture.SetPixel(x, y, Color.clear);
                    }
                }
                else
                {
                    newTexture.SetPixel(x, y, Color.clear);
                }
            }
        }
        newTexture.Apply();

        Sprite newSprite = Sprite.Create(newTexture, new Rect(0, 0, newTexture.width, newTexture.height), new Vector2(0.5f, 0.5f));

        SetupNewSprite(newSprite);
    }

    private Vector2Int WorldToTextureCoordinates(Vector3 worldPos, Camera cam, int texWidth, int texHeight)
    {
        Vector3 screenPos = cam.WorldToScreenPoint(worldPos);
        Vector2 texturePos = new Vector2(
            screenPos.x / cam.pixelWidth * texWidth,
            screenPos.y / cam.pixelHeight * texHeight);
        return new Vector2Int(Mathf.RoundToInt(texturePos.x), Mathf.RoundToInt(texturePos.y));
    }

    protected virtual void SetupNewSprite(Sprite newSprite)
    {
        SpriteRenderer test = new GameObject("TEST").AddComponent<SpriteRenderer>();
        test.sprite = newSprite;
        test.material = _customMaterial;

        //_reference.sprite = newSprite;
        //_reference.material = _customMaterial;
    }
}
