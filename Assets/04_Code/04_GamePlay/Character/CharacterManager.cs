using UnityEngine;
using NaughtyAttributes;

[RequireComponent(typeof(CharacterMovement))]
public class CharacterManager : MonoBehaviour
{
    [Required][SerializeField] private CharacterController _Controller;
    [Required][SerializeField] private CharacterMovement _Movement;

    [Header("Character values")]
    [SerializeField] private float _Speed = 1000f;

    private bool _IsInitialized = false;

    private bool _IsMoving = false;


    public void Start()
    {
        Initialize();
    }

    public override string ToString()
    {
        return ("");
    }

    private void Initialize()
    {
        if (_IsInitialized)
        {
            return;
        }


        _IsInitialized = true;
    }

    public void GiveMoveInput(Vector2 newDir)
    {
        Vector2 modifiedDir = newDir;

        if (!CanCharacterMove())
        {
            modifiedDir = Vector2.zero;
        }
        _Movement.GiveInput(modifiedDir);

        if (newDir == Vector2.zero || !CanCharacterRotate())
        {
            if (_IsMoving)
            {
                _IsMoving = false;
            }
        }
        else
        {
        }
    }

    public bool CanCharacterMove()
    {
        //if (IsPlayingSkill())
        //{
        //    return (false);
        //}

        return (true);
    }

    public bool CanCharacterRotate()
    {
        //if (IsPlayingSkill())
        //{
        //    return (false);
        //}

        return (true);
    }

    #region Getters

    public float GetCurrentMovementSpeed() => (_Speed);

    #endregion
}
