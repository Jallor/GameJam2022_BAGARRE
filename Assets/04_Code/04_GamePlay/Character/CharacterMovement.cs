using NaughtyAttributes;
using UnityEngine;

[RequireComponent(typeof(Rigidbody2D))]
public class CharacterMovement : MonoBehaviour
{
    [Required] [SerializeField] protected CharacterManager _CharaManager;
    [Required] [SerializeField] private Rigidbody2D _Rigidbody2D;

    private Vector2 _LastInputs;
    public void Update()
    {
        _Rigidbody2D.velocity /= 100;
        _Rigidbody2D.AddForce(_LastInputs * Time.deltaTime * _CharaManager.GetCurrentMovementSpeed());
    }

    public void GiveInput(Vector2 newInput)
    {
        _LastInputs = newInput;
    }
}
