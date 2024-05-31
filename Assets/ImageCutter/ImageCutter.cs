using UnityEngine;
using UnityEngine.UI;

public class ImageCutter : MonoBehaviour
{
    [Header("Cutter Dependencies")]
    [SerializeField] private int _renderLayerIndex;
    [SerializeField] private Camera _renderCamera;
    [SerializeField] private RenderTexture _renderTexture;
    [SerializeField] private Canvas _renderCanvas;

    [Header("Cutter Target Properties")]
    [SerializeField] private Image _target;
    [SerializeField] private Image _output;

    [ContextMenu("Create Cuted Texture")]
    public void Cut()
    {
        if (_renderCamera == null || _renderTexture == null || _target == null || _output == null)
        {
            Debug.LogError("Please assign all the required references");
            return;
        }

        GameObject targetCloned = Instantiate(_target.gameObject, _renderCanvas.transform);
        targetCloned.transform.position = Vector3.zero;
        targetCloned.transform.localScale = Vector3.one;
        targetCloned.layer = _renderLayerIndex;

        float originalSize = _renderCamera.orthographicSize;

        AdjustCanvasSize();
        AdjustCameraToCanvas();

        _renderCamera.targetTexture = _renderTexture;
        _renderCamera.transform.position = new Vector3(0, 0, -10);

        RenderTexture.active = _renderTexture;
        _renderCamera.Render();

        Texture2D texture2D = new Texture2D(_renderTexture.width, _renderTexture.height, TextureFormat.RGBA32, false);
        texture2D.ReadPixels(new Rect(0, 0, _renderTexture.width, _renderTexture.height), 0, 0);
        texture2D.Apply();
        RenderTexture.active = null;

        Sprite newSprite = Sprite.Create(texture2D, new Rect(0, 0, texture2D.width, texture2D.height), new Vector2(0.5f, 0.5f));

        _output.sprite = newSprite;
        _renderCamera.orthographicSize = originalSize;

        _output.rectTransform.sizeDelta = _target.rectTransform.sizeDelta;

        DestroyImmediate(targetCloned);
    }

    private void AdjustCanvasSize()
    {
        RectTransform canvasRectTransform = _renderCanvas.GetComponent<RectTransform>();
        RectTransform imageRectTransform = _target.GetComponent<RectTransform>();

        float imageWidth = imageRectTransform.rect.width * imageRectTransform.localScale.x;
        float imageHeight = imageRectTransform.rect.height * imageRectTransform.localScale.y;

        canvasRectTransform.sizeDelta = new Vector2(imageWidth, imageHeight);

        canvasRectTransform.position = imageRectTransform.position;
    }

    private void AdjustCameraToCanvas()
    {
        RectTransform canvasRect = _renderCanvas.GetComponent<RectTransform>();

        float canvasWidth = canvasRect.rect.width * canvasRect.localScale.x;
        float canvasHeight = canvasRect.rect.height * canvasRect.localScale.y;

        _renderCamera.orthographicSize = canvasHeight / 2;
        _renderCamera.aspect = canvasWidth / canvasHeight;

        _renderCamera.transform.position = new Vector3(
            canvasRect.position.x,
            canvasRect.position.y,
            _renderCamera.transform.position.z
        );
    }

    public void SetupCutter(Image target, Image output)
    {
        _target = target;
        _output = output;
    }

    public void SetupCutter(Image target)
    {
        _target = _output = target;
    }
}
