/// @desc Creates a stackable item struct
/// @param _name
/// @param _count

function item_create(_name, _count) {
    var data = item_get_data(_name);
    if (is_undefined(data)) return noone;

    return {
        name: _name,
        count: _count,
        data: data
    };
}