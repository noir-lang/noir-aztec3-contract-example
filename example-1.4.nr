use abi;
use execution_context::{ExecutionContext};
use note::Note;
use set::{Set};
use mapping::{Mapping}

contract PrivateToken {
    /**********************************/
    global balances = Mapping::new(/*storage_slot*/ 1);
    // Should eventually be replaced by:
    // `balances: Mapping<Field, Set<Note>>;`
    /**********************************/
    
    fn constructor(
        /**********************************/
        // Should eventually be hidden:
        call_context: abi::CallContext, 
        contract_deployment_data: abi::ContractDeploymentData,
        /**********************************/
        
        initial_supply: Field, owner: Point
    ) {
        /**********************************/
        // Should eventually be hidden:
        let mut public_inputs: pub abi::PublicInputs = abi::PublicInputs::new();
        
        public_inputs.call_context = call_context;
        public_inputs.contract_deployment_data = contract_deployment_data;
        
        public_inputs.args[0] = initial_supply;
        public_inputs.args[1] = owner.x;
        public_inputs.args[2] = owner.y;
        
        let exec_ctx = ExecutionContext::new(public_inputs);
        /**********************************/
         
        let owner_balance = balances.at(owner.x);
        let note = Note::new(initial_supply, owner);
        
        owner_balance.insert(exec_ctx, note);
        
        /**********************************/
        // Eventually hidden:
        exec_ctx // Return this, but NOT PUBLIC!
        /**********************************/
    }
    
    
    fn transfer(
        /**********************************/
        // Should eventually be hidden:
        call_context: abi::CallContext, 
        contract_deployment_data: abi::ContractDeploymentData,
        /**********************************/
        
        amount: Field, sender: Point, recipient: Point
    ) {
        /**********************************/
        // Should eventually be hidden:
        public_inputs: pub abi::PublicInputs,
        
        public_inputs.call_context = call_context;
        public_inputs.contract_deployment_data = contract_deployment_data;
        
        public_inputs.args[0] = value;
        public_inputs.args[1] = sender.x;
        public_inputs.args[2] = sender.y;
        public_inputs.args[3] = recipient.x;
        public_inputs.args[4] = recipient.y;
        
        let exec_ctx: ExecutionContext = init_exec_ctx(public_inputs);
        /**********************************/
        
        let sender_balance = balances.at(sender.x);
        let sender_notes = sender_balance.get_2(exec_ctx);
        
        let mut sum = 0;
        for i in 0..2 {
            let note = sender_notes[i];
            if note.is_dummy {
                constrain note.value == 0;
            }
            constrain sender == note.owner;
            sum += note.value;
        }
        
        constrain sum >= amount;
        
        let change_value = sum - amount;
        
        sender_balance.remove(exec_ctx, sender_notes[0]);
        sender_balance.remove(exec_ctx, sender_notes[1]);
        
        let recipient_note = Note::new(amount, recipient)
        let change_note = Note::new(change_value, sender);
        
        let recipient_balance = balances.at(recipient.x);
        recipient_balance.insert(exec_ctx, recipient_note);
        
        sender_balance.insert(exec_ctx, change_note);
        
        /**********************************/
        // Eventually hidden:
        exec_ctx // Return this, but NOT PUBLIC!
        /**********************************/
    }
}
