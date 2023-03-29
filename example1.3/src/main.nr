contract PrivateToken {
    use dep::aztec3::context::Context;
    use dep::aztec3::note::Note;
    use dep::aztec3::note::Point;
    use dep::aztec3::set::Set;
    use dep::aztec3::abi;

    //*********************************/
    global a = Set { storage_slot: 1 };
    // Should eventually be replaced by:
    // `a: Set<Note>;`
    //*********************************/
    fn constructor(
        context : pub Context,
    ) {
        let value = context.public_inputs.args[0];
        let owner = Point{
            x: context.public_inputs.args[1],
            y: context.public_inputs.args[2]
        };

        let note = Note::new(value, owner);
        a.insert(context, note);
    }
}
