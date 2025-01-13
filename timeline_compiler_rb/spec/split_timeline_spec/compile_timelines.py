from os import path

from timeline_compiler import compile_timelines

if __name__ == "__main__":
    current_location = path.dirname(__file__)
    compile_timelines(
        timelines_directory=path.join(current_location, "timelines"),
        expected_timelines_path=path.join(current_location, "expected.txt"),
        images_directory=path.join(current_location, "images"),
        output_path=path.join(current_location, "out_py.js")
    )
