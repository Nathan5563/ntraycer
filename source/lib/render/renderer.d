module lib.render.renderer;

import lib.scene.world : World;
import lib.render.film : Film;

class Renderer
{
    Film film;

    this(const int width, const int height)
    {
        this.film = new Film(width, height);
    }

    void render(ref const World world)
    {
        return;
    }
}

// TODO: UNIT TESTS
