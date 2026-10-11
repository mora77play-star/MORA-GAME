
using UnityEngine;
using System.Collections.Generic;

public class MoraGame : MonoBehaviour
{
    [Header("Game Settings")]
    public float moveSpeed = 7f;
    public float jumpForce = 7f;
    public float ropeLength = 4f;
    public float dogSpeed = 3.5f;

    private Rigidbody p1;
    private Rigidbody p2;
    private Rigidbody dog;
    private SpringJoint rope;
    private Camera cam;

    private bool climbing1;
    private bool climbing2;
    private bool jump1;
    private bool jump2;

    private float h1;
    private float v1;
    private float h2;
    private float v2;

    private readonly List<GameObject> world =
        new List<GameObject>();

    void Start()
    {
        Application.targetFrameRate = 60;
        Physics.gravity = new Vector3(0, -22f, 0);

        CreateGround();
        CreateBuildings();
        CreateObstacles();

        p1 = CreatePlayer(
            "Mora",
            new Vector3(-1, 1, 0),
            new Color(0.1f, 0.75f, 1f));

        p2 = CreatePlayer(
            "Friend",
            new Vector3(1, 1, 0),
            new Color(1f, 0.2f, 0.45f));

        CreateRope();
        CreateDog();
        CreateCamera();

        Debug.Log("MORA GAME READY!");
    }

    GameObject Cube(
        string name,
        Vector3 position,
        Vector3 scale,
        Color color)
    {
        GameObject obj = GameObject.CreatePrimitive(
            PrimitiveType.Cube);

        obj.name = name;
        obj.transform.position = position;
        obj.transform.localScale = scale;

        Renderer r = obj.GetComponent<Renderer>();
        r.material.color = color;

        world.Add(obj);
        return obj;
    }

    void CreateGround()
    {
        Cube(
            "Egyptian Ground",
            new Vector3(0, -0.5f, 0),
            new Vector3(250, 1, 250),
            new Color(0.72f, 0.62f, 0.42f));

        RenderSettings.ambientLight =
            new Color(0.65f, 0.65f, 0.7f);

        GameObject sun = new GameObject("Sun");
        Light light = sun.AddComponent<Light>();
        light.type = LightType.Directional;
        light.intensity = 1.3f;
        sun.transform.rotation =
            Quaternion.Euler(45, -30, 0);
    }

    void CreateBuildings()
    {
        for (int i = 0; i < 40; i++)
        {
            float x = Random.Range(-70f, 70f);
            float z = Random.Range(-70f, 70f);

            if (Mathf.Abs(x) < 12 &&
                Mathf.Abs(z) < 12)
                continue;

            float height = Random.Range(4f, 12f);

            Cube(
                "Egyptian Building",
                new Vector3(x, height / 2f, z),
                new Vector3(
                    Random.Range(4f, 8f),
                    height,
                    Random.Range(4f, 8f)),
                new Color(
                    Random.Range(0.6f, 0.9f),
                    Random.Range(0.45f, 0.7f),
                    0.4f));
        }
    }

    void CreateObstacles()
    {
        for (int i = 0; i < 18; i++)
        {
            float z = 8 + i * 4f;

            Cube(
                "Obstacle",
                new Vector3(
                    Random.Range(-6f, 6f),
                    0.6f,
                    z),
                new Vector3(2, 1.2f, 2),
                Color.magenta);
        }

        // A large climbable ladder-like staircase.
        for (int i = 0; i < 12; i++)
        {
            float height = i * 0.65f;

            Cube(
                "Climbing Step",
                new Vector3(
                    5,
                    height,
                    22 + i * 1.2f),
                new Vector3(3, 0.35f, 1.2f),
                new Color(0.5f, 0.27f, 0.12f));
        }
    }

    Rigidbody CreatePlayer(
        string name,
        Vector3 position,
        Color color)
    {
        GameObject player = GameObject.CreatePrimitive(
            PrimitiveType.Capsule);

        player.name = name;
        player.transform.position = position;

        player.GetComponent<Renderer>()
            .material.color = color;

        Rigidbody rb = player.AddComponent<Rigidbody>();
        rb.mass = 1.2f;
        rb.drag = 0.4f;
        rb.angularDrag = 0.8f;
        rb.interpolation = RigidbodyInterpolation.Interpolate;
        rb.collisionDetectionMode =
            CollisionDetectionMode.Continuous;

        rb.constraints = RigidbodyConstraints.None;
        rb.constraints |=
            RigidbodyConstraints.FreezeRotationX;
        rb.constraints |=
            RigidbodyConstraints.FreezeRotationZ;

        return rb;
    }

    void CreateRope()
    {
        rope = p1.gameObject.AddComponent<SpringJoint>();

        rope.connectedBody = p2;
        rope.autoConfigureConnectedAnchor = false;

        rope.anchor = new Vector3(0, 0.35f, 0);
        rope.connectedAnchor = new Vector3(0, 0.35f, 0);

        rope.minDistance = 1.5f;
        rope.maxDistance = ropeLength;
        rope.spring = 45f;
        rope.damper = 8f;
        rope.massScale = 1f;
    }

    void CreateDog()
    {
        GameObject obj = GameObject.CreatePrimitive(
            PrimitiveType.Capsule);

        obj.name = "Crazy Egyptian Dog";
        obj.transform.position = new Vector3(6, 1, 8);
        obj.transform.localScale =
            new Vector3(1.2f, 0.65f, 1.6f);

        obj.GetComponent<Renderer>().material.color =
            new Color(0.45f, 0.23f, 0.1f);

        dog = obj.AddComponent<Rigidbody>();
        dog.mass = 4f;
        dog.constraints =
            RigidbodyConstraints.FreezeRotation;
    }

    void CreateCamera()
    {
        GameObject cameraObject =
            new GameObject("Main Camera");

        cam = cameraObject.AddComponent<Camera>();
        cam.tag = "MainCamera";
        cam.fieldOfView = 70;

        cameraObject.AddComponent<AudioListener>();
    }

    void Update()
    {
        // Player 1: WASD + Space.
        h1 = Input.GetAxisRaw("Horizontal");
        v1 = Input.GetAxisRaw("Vertical");

        if (Input.GetKeyDown(KeyCode.Space))
            jump1 = true;

        // Player 2: Arrow keys + Right Control.
        h2 = 0;
        v2 = 0;

        if (Input.GetKey(KeyCode.LeftArrow)) h2 = -1;
        if (Input.GetKey(KeyCode.RightArrow)) h2 = 1;
        if (Input.GetKey(KeyCode.DownArrow)) v2 = -1;
        if (Input.GetKey(KeyCode.UpArrow)) v2 = 1;

        if (Input.GetKeyDown(KeyCode.RightControl))
            jump2 = true;

        // Hold E to pull your friend.
        if (Input.GetKey(KeyCode.E))
            rope.maxDistance = 2f;
        else
            rope.maxDistance = ropeLength;
    }

    void FixedUpdate()
    {
        MovePlayer(p1, h1, v1, ref jump1);
        MovePlayer(p2, h2, v2, ref jump2);

        ChaseDog();
        FollowPlayers();
    }

    void MovePlayer(
        Rigidbody rb,
        float horizontal,
        float vertical,
        ref bool jump)
    {
        Vector3 input =
            new Vector3(horizontal, 0, vertical);

        if (input.sqrMagnitude > 1)
            input.Normalize();

        Vector3 velocity = rb.linearVelocity;

        Vector3 desired =
            input * moveSpeed;

        rb.linearVelocity = new Vector3(
            desired.x,
            velocity.y,
            desired.z);

        if (jump && IsGrounded(rb))
        {
            rb.AddForce(
                Vector3.up * jumpForce,
                ForceMode.Impulse);
        }

        jump = false;
    }

    bool IsGrounded(Rigidbody rb)
    {
        return Physics.Raycast(
            rb.position,
            Vector3.down,
            1.15f);
    }

    void ChaseDog()
    {
        if (dog == null) return;

        Rigidbody target =
            Vector3.Distance(dog.position, p1.position) <
            Vector3.Distance(dog.position, p2.position)
                ? p1 : p2;

        Vector3 direction =
            target.position - dog.position;

        direction.y = 0;

        if (direction.magnitude > 1.5f)
        {
            Vector3 velocity =
                direction.normalized * dogSpeed;

            dog.linearVelocity = new Vector3(
                velocity.x,
                dog.linearVelocity.y,
                velocity.z);
        }
    }

    void FollowPlayers()
    {
        if (cam == null) return;

        Vector3 center =
            (p1.position + p2.position) * 0.5f;

        Vector3 desired =
            center + new Vector3(0, 7, -10);

        cam.transform.position = Vector3.Lerp(
            cam.transform.position,
            desired,
            Time.fixedDeltaTime * 4f);

        cam.transform.LookAt(center + Vector3.up);
    }

    void OnGUI()
    {
        GUIStyle style = new GUIStyle(
            GUI.skin.label);

        style.fontSize = 24;
        style.normal.textColor = Color.white;

        GUI.Label(
            new Rect(15, 15, 400, 40),
            "😂 MORA: TIED TOGETHER",
            style);

        GUI.Label(
            new Rect(15, 50, 450, 35),
            "WASD + SPACE | Arrows + CTRL",
            style);

        GUI.Label(
            new Rect(15, 85, 450, 35),
            "Hold E to pull your friend!",
            style);
    }
}
