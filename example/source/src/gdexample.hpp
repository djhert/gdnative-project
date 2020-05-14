#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <gdregistry/gdregistry.hpp>

#include <Godot.hpp>
#include <Sprite.hpp>

namespace godot {

class GDExample : public Sprite {
	GDCLASS(GDExample, Sprite)

private:
	float time_passed;

public:
	void _process(float delta);
};

} // namespace godot

#endif