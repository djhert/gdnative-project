#include "gdexample.hpp"

using namespace godot;

GDREGISTER(GDExample)

void GDExample::_register_methods() {
	register_method("_process", &GDExample::_process);
}

GDExample::~GDExample() {
	// add your cleanup here
}

void GDExample::_init() {
	// Showing the versioning
#ifdef _VERSIONED
	Godot::print(_EXAMPLE_INFO);
#endif
	// initialize any variables here
	time_passed = 0.0;
}

void GDExample::_process(float delta) {
	time_passed += delta;

	Vector2 new_position = Vector2(10.0 + (10.0 * sin(time_passed * 2.0)), 10.0 + (10.0 * cos(time_passed * 1.5)));

	set_position(new_position);
}