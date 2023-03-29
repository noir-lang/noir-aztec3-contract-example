contract PrivateToken {
    use dep::aztec3::abi;
    use dep::aztec3::context::Context;
    use dep::aztec3::note::Note;
    use dep::aztec3::note::Point;
    use dep::aztec3::set::Set;
    use dep::aztec3::map::Map;

    //*********************************/
    global balances = Map { storage_slot: 1 };
    // Should eventually be replaced by:
    // `balances: Mapping<Field, Set<Note>>;`
    //*********************************/

    fn constructor(
        //*********************************/
        // Should eventually be hidden:
        call_context: pub abi::CallContext, 
        contract_deployment_data: pub abi::ContractDeploymentData,
        //*********************************/

        initial_supply: pub Field, 
        owner: pub Point,
    ) -> pub Context {
        //*********************************/
        // Should eventually be hidden:
        let mut public_inputs = abi::PublicInputs::empty();

        public_inputs.call_context = call_context;
        public_inputs.contract_deployment_data = contract_deployment_data;

        public_inputs.args = public_inputs.args.push(initial_supply);
        public_inputs.args = public_inputs.args.push(owner.x);
        public_inputs.args = public_inputs.args.push(owner.y);

        let mut ctx = Context::new(public_inputs);
        //*********************************/

        let owner_balance = balances.at(owner.x);
        let note = Note::new(initial_supply, owner);

        owner_balance.insert(ctx, note)

        //*********************************/
        // Eventually hidden:
        // ctx // Return this, but NOT PUBLIC!
        //*********************************/
    }

    fn transfer(
        //*********************************/
        // Should eventually be hidden:
        call_context: pub abi::CallContext, 
        contract_deployment_data: pub abi::ContractDeploymentData,
        //*********************************/
        
        amount: pub Field, 
        sender: pub Point, 
        recipient: pub Point
    ) -> pub Context {
        //*********************************/
        // Should eventually be hidden:
        let mut public_inputs = abi::PublicInputs::empty();

        public_inputs.call_context = call_context;
        public_inputs.contract_deployment_data = contract_deployment_data;

        public_inputs.args = public_inputs.args.push(amount);
        public_inputs.args = public_inputs.args.push(sender.x);
        public_inputs.args = public_inputs.args.push(sender.y);
        public_inputs.args = public_inputs.args.push(recipient.x);
        public_inputs.args = public_inputs.args.push(recipient.y);

        let ctx1 = Context::new(public_inputs);
        //*********************************/

        let sender_balance = balances.at(sender.x);
        let (mut ctx, sender_notes) = sender_balance.get_2(ctx1);

        let mut sum = 0;
        for i in 0..2 {
            let note = sender_notes[i];
            if note.is_dummy {
                constrain note.value == 0;
            }
            constrain sender.x == note.owner.x;
            constrain sender.y == note.owner.y;
            sum += note.value;
        }

        constrain sum as u64 >= amount as u64;

        let change_value = sum - amount;

        ctx = sender_balance.remove(ctx, sender_notes[0]);
        ctx = sender_balance.remove(ctx, sender_notes[1]);

        let recipient_note = Note::new(amount, recipient);
        let change_note = Note::new(change_value, sender);

        let recipient_balance = balances.at(recipient.x);
        ctx = recipient_balance.insert(ctx, recipient_note);

        ctx = sender_balance.insert(ctx, change_note);

        //*********************************/
        // Eventually hidden:
        ctx // Return this, but NOT PUBLIC!
        //*********************************/
    }
}
