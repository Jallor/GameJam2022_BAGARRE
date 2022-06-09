using UnityEngine;
using NaughtyAttributes;

// TODO : Character controller
public class CharacterController : MonoBehaviour
{
    [Required] [SerializeField] protected CharacterManager _CharaManager;

    public CharacterManager GetCharaManager() => _CharaManager;
}
