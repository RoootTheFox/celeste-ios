using System;
using System.Reflection;
using SDL2;

namespace celestemeow
{
    public class Application
    {

        static void Main(string[] args)
#if __IOS__ || __TVOS__
        {
            /*
            Console.WriteLine("adding silly exception listener");
            AppDomain.CurrentDomain.FirstChanceException += (sender, eventArgs) => {
                Console.WriteLine("EXCEPTION: " + eventArgs.Exception.ToString());
            };
            */

            Console.WriteLine("running from ios - enabling workarounds!");
            // Enable high DPI "Retina" support. Trust us, you'll want this.
            Environment.SetEnvironmentVariable("FNA_GRAPHICS_ENABLE_HIGHDPI", "1");

            // Keep mouse and touch input separate.
            SDL2.SDL.SDL_SetHint(SDL.SDL_HINT_MOUSE_TOUCH_EVENTS, "0");
            SDL2.SDL.SDL_SetHint(SDL.SDL_HINT_TOUCH_MOUSE_EVENTS, "0");

            Console.WriteLine("setting SDL hint FNA3D_FORCE_DRIVER to Metal");
            SDL2.SDL.SDL_SetHint("FNA3D_FORCE_DRIVER", "Metal");

            realArgs = args;
            SDL2.SDL.SDL_UIKitRunApp(0, IntPtr.Zero, FakeMain);
        }

        static string[] realArgs;

        [ObjCRuntime.MonoPInvokeCallback(typeof(SDL2.SDL.SDL_main_func))]
        static int FakeMain(int argc, IntPtr argv)
        {
            RealMain(realArgs);
            return 0;
        }

        static void RealMain(string[] args)
#endif
        {
            Console.WriteLine("hello hi :3");

            // thanks to pixel#0772 on the celeste discord server for this <3
            //Type MeWhenIStealCodeFromAScreenshotInTheCelesteDiscordServer = typeof(UIWindow).GetType();
            MethodInfo method = typeof(Celeste.Celeste).GetMethod("Main", BindingFlags.NonPublic | BindingFlags.Static);
            method.Invoke(null, new object[] { args });
        }
    }
}
