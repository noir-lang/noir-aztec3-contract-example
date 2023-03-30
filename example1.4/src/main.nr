contract PrivateToken {
    use dep::aztec3::abi::Inputs;
    use dep::aztec3::abi::Outputs;
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
        // call_context: pub abi::CallContext, 
        // contract_deployment_data: pub abi::ContractDeploymentData,
        // //*********************************/

        // initial_supply: pub Field, 
        // owner: pub Point,
        inputs: pub Inputs,
    ) -> pub Outputs {
        //*********************************/
        // Should eventually be hidden:
        // let mut public_inputs = abi::PublicInputs::empty();

        // public_inputs.call_context = call_context;
        // public_inputs.contract_deployment_data = contract_deployment_data;

        let initial_supply = inputs.args[0];
        let owner = Point::new(inputs.args[1], inputs.args[2]);

        let mut outputs = Outputs::new();
        //*********************************/

        let owner_balance = balances.at(owner.x);
        let note = Note::new(initial_supply, owner);

        owner_balance.insert(inputs, outputs, note)
            .finish()

        //*********************************/
        // Eventually hidden:
        // ctx // Return this, but NOT PUBLIC!
        //*********************************/
    }

    fn transfer(
        //*********************************/
        // Should eventually be hidden:
        // call_context: pub abi::CallContext, 
        // contract_deployment_data: pub abi::ContractDeploymentData,
        // //*********************************/
        // 
        // amount: pub Field, 
        // sender: pub Point, 
        // recipient: pub Point
        inputs: pub Inputs,
    ) -> pub Outputs {
        //*********************************/
        // Should eventually be hidden:
        // let mut public_inputs = abi::PublicInputs::empty();

        // public_inputs.call_context = call_context;
        // public_inputs.contract_deployment_data = contract_deployment_data;

        let amount = inputs.args[0];
        let sender = Point::new(inputs.args[1], inputs.args[2]);
        let recipient = Point::new(inputs.args[3], inputs.args[4]);

        let outputs1 = Outputs::new();
        //*********************************/

        let sender_balance = balances.at(sender.x);
        let (mut outputs, sender_notes) = sender_balance.get_2(inputs, outputs1);

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

        constrain sum as u64 >= (amount as u64);

        let change_value = sum - amount;

        outputs = sender_balance.remove(inputs, outputs, sender_notes[0]);
        outputs = sender_balance.remove(inputs, outputs, sender_notes[1]);

        let recipient_note = Note::new(amount, recipient);
        let change_note = Note::new(change_value, sender);

        let recipient_balance = balances.at(recipient.x);
        outputs = recipient_balance.insert(inputs, outputs, recipient_note);

        outputs = sender_balance.insert(inputs, outputs, change_note);

        //*********************************/
        // Eventually hidden:
        outputs.finish() // Return this, but NOT PUBLIC!
        //*********************************/
    }
}
