contract PrivateToken {
    use dep::aztec3::context::Context;
    use dep::aztec3::note::Note;
    use dep::aztec3::note::Point;
    use dep::aztec3::set::Set;
    use dep::aztec3::abi;

    //*********************************/
    // global a = Set::new(/*storage_slot*/ 1);
    // Should eventually be replaced by:
    // `a: Set<Note>;`
    //*********************************/

    fn constructor(
        //*********************************/
        // Should eventually be hidden:
        call_context: abi::CallContext, 
        contract_deployment_data: abi::ContractDeploymentData,
        //**********************************/

        value: Field,
        owner: Point
    ) -> Context {
        //*********************************/
        // Should eventually be hidden:
        let mut public_inputs = abi::PublicInputs::empty();
        
        public_inputs.call_context = call_context;
        public_inputs.contract_deployment_data = contract_deployment_data;
        
        public_inputs.args[0] = value;
        public_inputs.args[1] = owner.x;
        public_inputs.args[2] = owner.y;
        
        let exec_ctx = Context::new(public_inputs);
        //*********************************/
         
        // let note = Note::new(value, owner);
        // a.insert(exec_ctx, note);
        
        //*********************************/
        // Eventually hidden:
        exec_ctx // Return this, but NOT PUBLIC!
        //*********************************/
    }
}
