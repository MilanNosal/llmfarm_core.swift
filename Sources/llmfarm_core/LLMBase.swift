//
//  LLMBase.swift
//  Created by Guinmoon.

import Foundation
import llmfarm_core_cpp

public enum ModelLoadError: Error {
    case modelLoadError
    case contextLoadError    
    case grammarLoadError
}


// protocol LLMInference {
//     func llm_sample() -> ModelToken
// }


public class LLMBase/*: LLMInference*/ {
    
    public var context: OpaquePointer?
    public var grammar: OpaquePointer?
    public var contextParams: ModelAndContextParams
    public var sampleParams: ModelSampleParams = .default    
    public var core_resourses = get_core_bundle_path()    
    public var session_tokens: [Int32] = []
    public var modelLoadProgressCallback: ((Float)  -> (Bool))? = nil    
    public var modelLoadCompleteCallback: ((String)  -> ())? = nil
    public var evalCallback: ((Int)  -> (Bool))? = nil
    public var evalDebugCallback: ((String)  -> (Bool))? = nil
    public var modelPath: String
    public var outputRepeatTokens: [ModelToken] = []
    
    // Used to keep old context until it needs to be rotated or purge out for new tokens
    var past: [[ModelToken]] = [] // Will house both queries and responses in order
    //var n_history: Int32 = 0
    public var nPast: Int32 = 0
    
    
    
    public  init(path: String, contextParams: ModelAndContextParams = .default) throws {
        
        self.modelPath = path
//        self.modelLoadProgressCallback = model_load_progress_callback
        self.contextParams = contextParams
        //        var params = gptneox_context_default_params()
        
        // Check if model file exists
        if !FileManager.default.fileExists(atPath: self.modelPath) {
            throw ModelError.modelNotFound(self.modelPath)
        }
        // load_model()
    }


    

    public func load_model() throws {
        var load_res:Bool? = false
        do{
            try ExceptionCather.catchException {
                load_res = try? self.llm_load_model(path:self.modelPath,contextParams:contextParams)
            }
        
            if load_res != true{
                throw ModelLoadError.modelLoadError
            }                        
            
            if self.contextParams.grammar_path != nil && self.contextParams.grammar_path! != ""{
                try? self.load_grammar(self.contextParams.grammar_path!)
            }
            
            print(String(cString: print_system_info()))
            try ExceptionCather.catchException {
                _ = try? self.llm_init_logits()
            }
    //        if exception != nil{
    //            throw ModelError.failedToEval
    //        }
            
            print("Logits inited.")
        }catch {
            print(error)
            throw error
        }
    }
    


    
    public func load_clip_model() -> Bool{
        return true
    }
    
    public func deinit_clip_model(){
        
    }
    
    public func destroy_objects(){
        
    }
    
    deinit {
        print("deinit LLMBase")
    }
    
    public func load_grammar(_ path:String) throws -> Void{
        do{
            // try ExceptionCather.catchException {
            //     self.grammar = llama_load_grammar(path)
            // }
        }
        catch {
            print(error)
            throw error
        }
    }
    
    public func llm_load_model(path: String = "",contextParams: ModelAndContextParams = .default) throws -> Bool
    {
        return false
    }
    
    
    public func resetContext() throws {
    }
    
    public func llm_token_is_eog(token: ModelToken) -> Bool{
        if token == llm_token_eos(){
            return true
        }
        return false
    }
    
    public func llm_token_nl() -> ModelToken{
        return 13
    }
    
    public func llm_token_bos() -> ModelToken{
        print("llm_token_bos base")
        return 0
        // return gpt_base_token_bos()
    }
    
    public func llm_token_eos() -> ModelToken{
        print("llm_token_eos base")
        return 0
        // return gpt_base_token_eos()
    }
    
    func llm_n_vocab(_ ctx: OpaquePointer!) -> Int32{
        print("llm_n_vocab base")
        return 0
        // return gpt_base_n_vocab(ctx)
    }
    
    func llm_get_logits(_ ctx: OpaquePointer!) -> UnsafeMutablePointer<Float>?{
        print("llm_get_logits base")
        return nil
        // return gpt_base_get_logits(ctx)
    }
    
    func llm_get_n_ctx(ctx: OpaquePointer!) -> Int32{
        print("llm_get_n_ctx base")
        return 0
        // return gpt_base_n_ctx(ctx)
    }
    
    public func make_image_embed(_ image_path:String) -> Bool{
        return true
    }
    
    // Simple topK, topP, temp sampling, with repeat penalty
    func llm_sample() -> ModelToken {
        return 0;
    }
//     func llm_sample() -> ModelToken {
//         // Model input context size
//         let ctx = self.context
//         var last_n_tokens =  self.outputRepeatTokens
//         let temp = self.sampleParams.temp
// //        let top_k = self.sampleParams.top_k
//         let top_p = self.sampleParams.top_p
//         let tfs_z = self.sampleParams.tfs_z
//         let typical_p = self.sampleParams.typical_p
// //        let repeat_last_n = self.sampleParams.repeat_last_n
//         let repeat_penalty = self.sampleParams.repeat_penalty
//         let alpha_presence = self.sampleParams.presence_penalty
//         let alpha_frequency = self.sampleParams.frequence_penalty
//         let mirostat = self.sampleParams.mirostat
//         let mirostat_tau = self.sampleParams.mirostat_tau
//         let mirostat_eta = self.sampleParams.mirostat_eta
//         let penalize_nl = self.sampleParams.penalize_nl

//         let n_ctx = llm_get_n_ctx(ctx: ctx)
//         // Auto params
        
//         let top_k = self.sampleParams.top_k <= 0 ? llm_n_vocab(ctx) : self.sampleParams.top_k
//         let repeat_last_n = self.sampleParams.repeat_last_n < 0 ? n_ctx : self.sampleParams.repeat_last_n
        
//         //
//         let vocabSize = llm_n_vocab(ctx)
//         guard let logits = llm_get_logits(ctx) else {
//             print("GPT sample error logits nil")
//             return 0
//         }
//         var candidates = Array<llama_dadbed9_token_data>()
//         for i in 0 ..< vocabSize {
//             candidates.append(llama_dadbed9_token_data(id: i, logit: logits[Int(i)], p: 0.0))
//         }
//         var candidates_p = llama_dadbed9_token_data_array(data: candidates.mutPtr, size: candidates.count, sorted: false)
        
//         // Apply penalties
//         let nl_token = Int(llm_token_nl())
//         let nl_logit = logits[nl_token]
//         let last_n_repeat = min(min(Int32(last_n_tokens.count), repeat_last_n), n_ctx)
        
//         llama_dadbed9_sample_repetition_penalty(&candidates_p,
//                     last_n_tokens.mutPtr.advanced(by: last_n_tokens.count - Int(repeat_last_n)),
//                     Int(repeat_last_n), repeat_penalty)
//         llama_dadbed9_sample_frequency_and_presence_penalties(ctx, &candidates_p,
//                     last_n_tokens.mutPtr.advanced(by: last_n_tokens.count - Int(repeat_last_n)),
//                     Int(last_n_repeat), alpha_frequency, alpha_presence)
//         if(!penalize_nl) {
//             logits[nl_token] = nl_logit
//         }
        
// //         if (self.grammar != nil ) {
// // //            llama_sample_grammar(ctx,&candidates_p, self.grammar)
// //              llama_sample_grammar_for_dadbed9(ctx,&candidates_p, self.grammar)
// //         }
        
//         var res_token:Int32 = 0
        
//         if(temp <= 0) {
//             // Greedy sampling
//             res_token = llama_dadbed9_sample_token_greedy(ctx, &candidates_p)
//         } else {
//             var class_name = String(describing: self)
//             if(mirostat == 1) {
//                 var mirostat_mu: Float = 2.0 * mirostat_tau
//                 let mirostat_m = 100
//                 llama_dadbed9_sample_temperature(ctx, &candidates_p, temp)
//                 res_token =  llama_dadbed9_sample_token_mirostat(ctx, &candidates_p, mirostat_tau, mirostat_eta, Int32(mirostat_m), &mirostat_mu, vocabSize);
//             } else if(mirostat == 2) {
//                 var mirostat_mu: Float = 2.0 * mirostat_tau
//                 llama_dadbed9_sample_temperature(ctx, &candidates_p, temp)
//                 res_token =  llama_dadbed9_sample_token_mirostat_v2(ctx, &candidates_p, mirostat_tau, mirostat_eta, &mirostat_mu)
//             } else {
//                 // Temperature sampling
//                 llama_dadbed9_sample_top_k(ctx, &candidates_p, top_k, 1)
//                 llama_dadbed9_sample_tail_free(ctx, &candidates_p, tfs_z, 1)
//                 llama_dadbed9_sample_typical(ctx, &candidates_p, typical_p, 1)
//                 llama_dadbed9_sample_top_p(ctx, &candidates_p, top_p, 1)
//                 llama_dadbed9_sample_temperature(ctx, &candidates_p, temp)
//                 res_token = llama_dadbed9_sample_token(ctx, &candidates_p)
//             }
//         }
        
// //        if (self.grammar != nil) {
// //            llama_dadbed9_grammar_accept_token(ctx, self.grammar, res_token);
// //        }
//         return res_token

//     }
    
    public func ForgotLastNTokens(_ N: Int32){ }
    
    public func load_state(){}
    
    public func save_state(){}
    
    
    public func llm_eval(inputBatch: inout [ModelToken]) throws -> Bool{
        return false
    }

    public func llm_eval_clip() throws -> Bool{
        return true
    }
    
    func llm_init_logits() throws -> Bool {
        do{
            var inputs = [llm_token_bos(),llm_token_eos()]
            try ExceptionCather.catchException {
                _ = try? llm_eval(inputBatch: &inputs)
            }
            return true
        }
        catch{
            print(error)
            throw error
        }
    }
    
    
    public func LLMTokenToStr(outputToken:Int32) -> String? {
        // if let cStr = gpt_base_token_to_str(context, outputToken){
        //     return String(cString: cStr)
        // }
        return nil
    }
    
    
    public func _eval_system_prompt(system_prompt:String? = nil) throws{
        if system_prompt != nil{
            var system_pormpt_Tokens = try TokenizePrompt(system_prompt ?? "", .None)            
            var eval_res:Bool? = nil
            try ExceptionCather.catchException {
                eval_res = try? self.llm_eval(inputBatch: &system_pormpt_Tokens)
            }
            if eval_res == false{
                throw ModelError.failedToEval
            }
            self.nPast += Int32(system_pormpt_Tokens.count)
        }
    }

    public func _eval_img(img_path:String? = nil) throws{
        if img_path != nil{
            do {  
                try ExceptionCather.catchException {
                    _ = self.load_clip_model()
                    _ = self.make_image_embed(img_path!)
                    _ = try? self.llm_eval_clip()
                    self.deinit_clip_model()
                }
             }catch{
                print(error)
                throw error
             }     
        }
    }
    
    public func KVShift() throws{
        self.nPast = self.nPast / 2
        try ExceptionCather.catchException {
            var in_batch = [self.llm_token_eos()]
            _ = try? self.llm_eval(inputBatch: &in_batch)
        }
        print("Context Limit!")
    }

    public func CheckSkipTokens (_ token:Int32) ->Bool{
        for skip in self.contextParams.skip_tokens{
            if skip == token{
                return false
            }
        }
        return true
    }

    public func EvalInputTokensBatched(inputTokens: inout [ModelToken],callback: ((String, Double) -> Bool)) throws -> Void {
        var inputBatch: [ModelToken] = []
        while inputTokens.count > 0 {
            inputBatch.removeAll()
            // See how many to eval (up to batch size??? or can we feed the entire input)
            // Move tokens to batch
            let evalCount = min(inputTokens.count, Int(sampleParams.n_batch))
            inputBatch.append(contentsOf: inputTokens[0 ..< evalCount])
            inputTokens.removeFirst(evalCount)

            if self.nPast + Int32(inputBatch.count) >= self.contextParams.context{
                try self.KVShift()
                _ = callback(" `C_LIMIT` ",0)
            }
            var eval_res:Bool? = nil
            try ExceptionCather.catchException {
                eval_res = try? self.llm_eval(inputBatch: &inputBatch)
            }
            if eval_res == false{
                throw ModelError.failedToEval
            }
            self.nPast += Int32(evalCount)
        }
    }

    public func Predict(_ input: String, _ evalCallback: ((String, Double) -> Bool),
                        system_prompt:String? = nil,
                        img_path: String? = nil,
                        infoCallback: ((String,Any) -> Void)? = nil ) throws -> String {
        //Eval system prompt then image if it's not nil
        if self.nPast == 0{
            try _eval_system_prompt(system_prompt:system_prompt)
        }
        try _eval_img(img_path:img_path)
        
        let contextLength = Int32(contextParams.context)
        print("Past token count: \(nPast)/\(contextLength) (\(past.count))")
        // Tokenize with prompt format
        do {
            var inputTokens = try TokenizePrompt(input, self.contextParams.promptFormat)
            infoCallback?("itc",inputTokens.count)
            
            if inputTokens.count == 0 && img_path == nil{
                return "Empty input."
            }
            let inputTokensCount = inputTokens.count
            print("Input tokens: \(inputTokens)")

            if inputTokensCount > contextLength {
                throw ModelError.inputTooLong
            }

            var inputBatch: [ModelToken] = []
        
            //Batched Eval all input tokens             
            try EvalInputTokensBatched(inputTokens: &inputTokens,callback:evalCallback)            
            // Output
            outputRepeatTokens = []
            var output = [String]()
            // Loop until target count is reached
            var completion_loop = true
            // let eos_token = llm_token_eos()
            while completion_loop {
                // Pull a generation from context
                var outputToken:Int32 = -1
                try ExceptionCather.catchException {
                    outputToken = self.llm_sample()
                }
                // Repeat tokens update
                outputRepeatTokens.append(outputToken)
                if outputRepeatTokens.count > sampleParams.repeat_last_n {
                    outputRepeatTokens.removeFirst()
                }
                // Check for eos - end early - check eos before bos in case they are the same
                // if outputToken == eos_token {
                //     completion_loop = false
                //     print("[EOS]")
                //     break
                // }
                if llm_token_is_eog(token:outputToken) {
                    completion_loop = true
                    print("[EOG]")
                    break
                }

                // Check for BOS and tokens in skip list
                var skipCallback = false
                if !self.CheckSkipTokens(outputToken){
                    print("Skip token: \(outputToken)")
                    skipCallback = true
                }
                // Convert token to string and callback             
                if !skipCallback, let str = LLMTokenToStr(outputToken: outputToken){
                    output.append(str)
                    // Per token callback
                     let (output, time) = Utils.time {
                         return str
                     }
                     if evalCallback(output, time) {
                        // Early exit if requested by callback
                        print(" * exit requested by callback *")
                        completion_loop = false 
                        break
                    }
                }
                // Max output tokens count reached                
                if (self.contextParams.n_predict != 0 && output.count>self.contextParams.n_predict){
                    print(" * n_predict reached *")
                    completion_loop = false 
                    break
                }
                // Check if we need to run another response eval
                if completion_loop {
                    // Send generated token back into model for next generation
                    var eval_res:Bool? = nil
                    if self.nPast >= self.contextParams.context - 2{
                        try self.KVShift()
                        _ = evalCallback(" `C_LIMIT` ",0)
                    }
                    try ExceptionCather.catchException {
                        inputBatch = [outputToken]
                        eval_res = try? self.llm_eval(inputBatch: &inputBatch)
                    }
                    if eval_res == false{
                        print("Eval res false")
                        throw ModelError.failedToEval
                    }
                    nPast += 1
                }
            }
            print("Total tokens: \(inputTokensCount + output.count) (\(inputTokensCount) -> \(output.count))")
            infoCallback?("otc",output.count)
            // print("Past token count: \(nPast)/\(contextLength) (\(past.count))")
            // Return full string for case without callback
            return output.joined()
        }catch{
            print(error)
            throw error
        }
    }

    
    public func LLMTokenize(_ input: String, add_bos: Bool? = nil, parse_special:Bool? = nil) -> [ModelToken] {
        return []
        // if input.count == 0 {
        //     return []
        // }
        
        // var embeddings = Array<ModelToken>(repeating: gpt_token(), count: input.utf8.count)
        // let n = gpt_base_tokenize(context, input, &embeddings, Int32(input.utf8.count), self.contextParams.add_bos_token)
        // if n<=0{
        //     return []
        // }
        // if Int(n) <= embeddings.count {
        //     embeddings.removeSubrange(Int(n)..<embeddings.count)
        // }
        
        // if self.contextParams.add_eos_token {
        //     embeddings.append(gpt_base_token_eos())
        // }
        
        // return embeddings
    }
    
    public func TokenizePrompt(_ input: String, _ style: ModelPromptStyle) throws -> [ModelToken] {
        switch style {
        case .None:
            return LLMTokenize(input)
        case .Custom:
            var formated_input = self.contextParams.custom_prompt_format.replacingOccurrences(of: "{{prompt}}", with: input)
            formated_input = formated_input.replacingOccurrences(of: "{prompt}", with: input)
            formated_input = formated_input.replacingOccurrences(of: "\\n", with: "\n")
            var tokenized:[ModelToken] = []
            try ExceptionCather.catchException {
                tokenized = LLMTokenize(formated_input)
            }
            return tokenized
         }
    }
    
    public func parse_skip_tokens(){
        // This function must be called after model loaded
        // Add BOS token to skip 
        self.contextParams.skip_tokens.append(self.llm_token_bos())

        let splited_skip_tokens = self.contextParams.skip_tokens_str.components(separatedBy: [","])
        for word in splited_skip_tokens{
            let tokenized_skip = self.LLMTokenize(word,add_bos: false,parse_special: true)
            // Add only if tokenized text is one token
            if tokenized_skip.count == 1{
                self.contextParams.skip_tokens.append(tokenized_skip[0])
            }
        }
        
    }
}


