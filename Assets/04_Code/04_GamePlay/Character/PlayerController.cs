using NaughtyAttributes;
using UnityEngine;

public class PlayerController : CharacterController
{
    public void Update()
    {
        //if (GameManager.Inst && !GameManager.Inst.CanCharactersAct())
        //{
        //    _CharaManager.GiveMoveInput(Vector2.zero);
        //    return;
        //}

        // TODO : PlayerController : Use axis
        Vector2 newDir = new Vector2();
        if (Input.GetKey(KeyCode.Z))
        {
            ++newDir.y;
        }
        if (Input.GetKey(KeyCode.S))
        {
            --newDir.y;
        }
        if (Input.GetKey(KeyCode.Q))
        {
            --newDir.x;
        }
        if (Input.GetKey(KeyCode.D))
        {
            ++newDir.x;
        }
        _CharaManager.GiveMoveInput(newDir);

        if (Input.GetKeyDown(KeyCode.T))
        {
            // _CharaManager.TryPlaySkill();
        }
    }
}
