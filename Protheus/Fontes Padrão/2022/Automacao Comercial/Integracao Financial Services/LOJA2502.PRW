#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA2502.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "XMLXFUN.CH"  

#DEFINE 	_L1_IFSANST_APROVADO 	"1"
#DEFINE 	_L1_IFSANST_REPROVADO 	"0"
#DEFINE 	_L1_IFSANST_MESA 		"2"   
#DEFINE 	_L1_IFSANST_OFFLINE 	"9"

Static cOperac :=  ""								//Tipo da operacao   R - Re-envio/ E - Envio            
Static cObsAnalise := ""            				//Observa็ใo da analise de Credito   
Static lProcessa   := .T.							//Variavel estatica para processar o retorno    


Function LOJA2502 ; EvalTrigger(.F.); Return  // "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    |LjClInFSAn       บAutor  ณVendas CRM          บ Data ณ  06/03/2012 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse de Integracao Financial Service - Analise Orcamento         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LjClInFSAn
   	
	Data cFilOrc                                                           //Filial do Or็amento
    Data nAcesso                                                           //Codigo do profile da rotina de estorno    
  	Data cOrcamento                                                        //Or็amento  
  	Data cObsAnalise                                                       //Observa็ใo da analise de credito
    Data cOperac                                                           //Operacao da analise de credito
    Data cArqLog                                                           //Diretorio do arquivo de log
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA2502  บAutor  ณVendas CRM          บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
	Method New()  
	Method ExibirFrm()                                              //Informar a observa็ใo do re-envio da anแlise de cr้dito
	Method AprovarAna()                                               //Aprova a analise de credito
	Method EnviarAnal()                                                ///Enviar a solicita็ใo de analise de credito
	Method ValidarApr()                                     //Verifica se pode ser realizada a aprova็ใo da analise ou atualizacao da analise
	Method ExecutarAp()									  //Executa aprovacao da analise de credito
	Method ReEnviarAna()                                               //Executa o re-envio da analise de credito reprovada
    Method AtualizarS()                                    //Atualizar o status da analise
    Method ExibirResp()                                    //Exibir o status da analise      
    Method LiberarOrc()                                    //Verifica se o orcamento pode ser liberado para venda
    Method ProcResp()									//Processa o retorno da mensagem EAI
    Method Destruct()

EndClass  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |New              บAutor  ณVendas CRM           บ Data ณ  28/02/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que Instancia o objeto                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ  
ฑฑบParametrosณ ExpC1 = Filial do Sistema                                         บฑฑ
ฑฑบ          ณ ExpC2 = Orcamento                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method New(cFilOrc	, cOrcamento)  Class LjClInFSAn  

	Local cGetCliDir := ""  //String do diretorio de log
	Local cProfStr1  := "" //String do TEF

	Self:cOrcamento 	:= cOrcamento
	Self:cFilOrc		:= cFilOrc
    Self:nAcesso		:= 31 
    Self:cObsAnalise    := ""   
    Self:cOperac		:= "" 
    Self:cArqLog        := ""
    	 
	If !IsBlind()    
		cGetCliDir := GetClientDir()
	
	    cProfStr1 := GetPvProfString("Logs TEF","Habilita","01",cGetCliDir + "SIGALOJA.INI")
	 
		If File(cGetCliDir + "SIGALOJA.INI") .AND. cProfStr1 == "01"
			Self:cArqLog  := "\AUTOCOM\TEF"+cEmpAnt+cFilAnt+"\"
		Else                         
			Self:cArqLog  := ""
		EndIf	  
	Endif   
 
    
Return Self   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | AprovarAna      บAutor  ณVendas CRM           บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que busca um orcamento                                       บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpC1 = Numero do Cupom                                            บฑฑ
ฑฑบ          ณ ExpC2 = Serie do Cupom                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AprovarAna() Class LjClInFSAn    
	Local lRet := .F. //Aprovacao de analise   
	
	If LjProfile(Self:nAcesso) .AND. Self:ValidarApr(,STR0001,_L1_IFSANST_MESA+"#"+_L1_IFSANST_OFFLINE) //"Liberacใo Anแlise de Cr้dito"
		lRet := Self:ExecutarAp()
	EndIf

Return lRet   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | EnviarAnal      บAutor  ณVendas CRM           บ Data ณ  06/03/2012 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza o envio da analise                               บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpC1 = Operacao "E" - Envio / "R" - Re-envio                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Method EnviarAnal(cOpera)  Class LjClInFSAn                                             ///Busca o Orcamento pelo WS
	Local aIntegDef := {}		// receberแ o retorno da integdef com a mensagem para envio
	Local oXMLEAI := nil	//Objeto da classe EAI  
	Local cResult := "" 	//Resposta do EAI        
	Local aMsgErr	:= {} //Array das mensagens de resposta
	
	Lj2502StOp(cOpera)
	Lj2502StOb(Self:cObsAnalise)   
	
	Lj2502StPr(.F.) //Trava o processamento para aguardar a resposta ou disparar o timeout
	
	
	oXMLEAI := LjClXMLEai():New("BusinessRequest", , , , "AnaliseCredito", "BusinessContent") 
	
	Self:AtualizarS(_L1_IFSANST_OFFLINE,"","")
	
	If !oXMLEAI:EnviaEAI("LOJA2507")   
		
		If !Empty(cResult := oXMLEAI:oFWEAI:cResult)
			cResult := StrTokArr(cResult,"|")    
			aEval(cResult, { |m| aAdd(aMsgErr, { nil, m} ) } ) 
			oXMLEAI:ExibirResp(cResult,aMsgErr)		
		EndIf
		
		If oXMLEAI <> NIL  
			oXMLEAI:Destruct()
			FreeObj(oXMLEAI)
			oXMLEAI := NIL
		EndIf
	Else
		
		cResult := oXMLEAI:oFWEAI:cResult
	
		If oXMLEAI <> NIL  
			oXMLEAI:Destruct()
			FreeObj(oXMLEAI)
			oXMLEAI := NIL
		EndIf	
		
		Self:ProcResp( cResult )   //Processa a Resposta 
	
	EndIf
	
Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |ValidarApr       บAutor  ณVendas CRM           บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que verifica se um or็amento pode ter analise aprovada       บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpL1 = Exibe a mensagem?                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method ValidarApr(lMsg,cOpera, cStatus, cMsg) Class LjClInFSAn    
	Local lRet := .F. //Orcamento pode Ser aprovado   
	Local aAliasSL1 := SL1->(GetArea())  //WorkArea SL1
	Local cMVCliPad := PadR(SuperGetMV("MV_CLIPAD") , TamSx3("L1_CLIENTE)")[1]) //Cliente padrao											// Cliente padrao
	Local cMVLojaPad:= PadR(SuperGetMV("MV_LOJAPAD") , TamSx3("L1_LOJA")[1])    //Loja do cliente padrao
	
	Default lMsg := .T. 
	DeFault cStatus := "" 
	Default cMsg := ""
	Default cOpera := ""
	
	SL1->(DbSetOrder(1))  //L1_FILIAL+L1_NUM                                                                                                                                                
	
	If SL1->(DbSeek(Self:cFilOrc + Self:cOrcamento))
	 
		 If IIF( !Empty(cStatus), SL1->L1_IFSANST $ cStatus, .T.) .AND. Empty(SL1->(L1_HRST+L1_USRST)) .AND. ;
		 	SL1->(Empty(L1_DOC) .AND. dDataBase <= L1_DTLIM .AND. L1_STATUS <> "D" .AND. IIf(SL1->(FieldPos("L1_STORC")) >0, L1_STORC <> "C", .T.)   .AND. (FieldPos("L1_STATUES") = 0 .Or. Empty(L1_STATUES))) .AND. ;
		 	SL1->(L1_CLIENTE + L1_LOJA) <> cMVCliPad + cMVLojaPad
		 	lRet := .T. 
		 Else
		 	
		 	cMsg := STR0015 + " " +  cOpera + STR0013 + IIF(!Empty(cStatus), STR0014 + StrTran(cStatus, "#", ","), "") //cMsg := "Para " + cOpera + ", o or็amento deverแ estar ativo, o cliente nใo poderแ ser o padrใo" + IIF(!Empty(cStatus) + " e o status da analise deverแ estar entre o(s) valor(es): " + StrTran(cStatus, "#", ","), "")
		 	
		 	If lMsg
		 		MsgAlert(cMsg)
		 	EndIf
		 EndIf
	 
	Else
		cMsg := STR0002 + Self:cOrcamento + STR0003 + Self:cFilOrc + STR0004	//"Or็amento: "#" da filial: "#" nใo localizado"
		If lMsg
			MsgAlert(cMsg)	
		EndIf
	EndIf
		
	RestArea(aAliasSL1)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | ExecutarAp      บAutor  ณVendas CRM           บData ณ  06/03/2012 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que verifica se um or็amento pode ter analise aprovada       บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpL1 = Exibe a mensagem?                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ExecutarAp() Class LjClInFSAn     
	Local nOp := 0  //Opcao selecionada pelo usuario
	Local aArea := nil //WorkArea ativa
	
	nOp:= Aviso(STR0005,STR0006,{STR0007,STR0008,STR0009})  //"Aten็ใo"#"Informe o status da anแlise de cr้dito"# Aprovar" # "Reprovar" #   "Canc Aprov" #"           
	
	If nOp > 0 .AND. nOp <= 2 // Aprovado Reprovado 
	             
	    aArea := GetArea()
	 	
	 	DbSelectArea("SL1")
	 	RecLock("SL1", .F.)     
	 	
	    REPLACE L1_IFSANST 	WITH IIF(nOp == 1, _L1_IFSANST_APROVADO, _L1_IFSANST_REPROVADO) 
	 	REPLACE L1_DTST 	WITH dDataBase
	 	REPLACE L1_HRST 	WITH StrTran(Time(), ":")
	 	REPLACE L1_USRST 	WITH RetCodUsr()  
	
	 	MsUnLock() 
	 	RestArea(aArea)
	
	Endif
	
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | AtualizarS      บAutor  ณVendas CRM           บ Data ณ  12/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que atualiza o status da analise                             บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AtualizarS(cStatus, cMsg1, cMsg2) Class LjClInFSAn     
	Local aArea := nil   	//WorkArea ativa
	Local cAntMsg1 := ""   	//Mensagem1 gravada no SL1
	Local cAntMsg2 := "" 	//Mensagem2 gravada no SL1
             
    aArea := GetArea()
 	
 	DbSelectArea("SL1")
 	RecLock("SL1", .F.) 
 	
    REPLACE L1_IFSANST 	WITH cStatus 
    
 	MsUnLock() 
 	
 	
 	If !Empty(L1_IFSCDM1)
 		cAntMsg1 := AllTrim(MSMM(L1_IFSCDM1,255))
 	EndIf 
 	
 	If !Empty(L1_IFSCDM2)
 		cAntMsg2 := AllTrim(MSMM(L1_IFSCDM2,255))
 	EndIf
 	
 	If !Empty(cMsg1) .AND. cAntMsg1 <> cMsg1  
 		MSMM(L1_IFSCDM1, 255	, NIL, cMsg1, ; 
		     1		, NIL				, NIL, "SL1"	, ;
		     "L1_IFSCDM1")	
 	ElseIf Empty(cMsg1) .AND. !Empty(cAntMsg1) 
 		MSMM(L1_IFSCDM1, 255	, NIL, cMsg1, ; 
		     2		, NIL				, NIL, "SL1"	, ;
		     "L1_IFSCDM1") 
		
		DbSelectArea("SL1")     
	 	RecLock("SL1", .F.) 
	 	
	    REPLACE L1_IFSCDM1 	WITH "" 
	    
	 	MsUnLock()	 	
 	EndIf
 	
 	If !Empty(cMsg2) .AND. cAntMsg2 <> cMsg2  
 		MSMM(L1_IFSCDM2, 255	, NIL, cMsg2, ; 
		     1		, NIL				, NIL, "SL1"	, ;
		     "L1_IFSCDM2")  
		     
 	
 	ElseIf Empty(cMsg2) .AND. !Empty(cAntMsg2)
 		MSMM(L1_IFSCDM2, 255	, NIL, cMsg2, ; 
		     2		, NIL				, NIL, "SL1"	, ;
		     "L1_IFSCDM2") 	
		     
	 	DbSelectArea("SL1")
	 	RecLock("SL1", .F.) 
	 	
	    REPLACE L1_IFSCDM2 	WITH "" 
	    
	 	MsUnLock()
 	EndIf
 	RestArea(aArea)


Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | ExibirResp      บAutor  ณVendas CRM           บ Data ณ  12/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que exibe o status da analise                                บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ExibirResp(lMsg) Class LjClInFSAn     
	Local aArea := nil  //WorkArea ativa
	Local cMsg := ""    //Mensagem conforme retorno no FS
	Local cMsg2 := ""   //Mensagem retornada pelo FS


	Default lMsg := .F. 
             
    aArea := GetArea()
 	
 	DbSelectArea("SL1")
    
	
	cMsg := STR0016 //"Este or็amento foi submetido เ anแlise de credito pelo sistema Financial Service e a resposta foi: "
 	
    Do Case   
    
    Case L1_IFSANST == _L1_IFSANST_APROVADO 
    	cMsg += STR0017 //"Aprovado"
    Case L1_IFSANST == _L1_IFSANST_REPROVADO
    	cMsg += STR0018 //"Reprovado"
    Case L1_IFSANST == _L1_IFSANST_MESA 
    	cMsg += STR0019 //"Mesa de Credito"
    Case L1_IFSANST == _L1_IFSANST_OFFLINE 
    	cMsg += STR0020 //"Sem anแlise, problemas na comunica็ใo"
    OtherWise
    	cMsg += STR0021 + " [" + L1_IFSANST + "]"  //"Status nใo tratado " + ## + "]"
    EndCase  
    
    
  	If !Empty(L1_IFSCDM2)
 		cMsg2 := AllTrim(MSMM(L1_IFSCDM2,255))
 	EndIf
 	
 	If !Empty(cMsg2)
 		cMsg += CRLF + STR0022 + " [" + cMsg2 + "]"   //"Mensagem de Retorno do Financial Service: "
 	EndIf
    
    If lMsg
    	MsgAlert(cMsg)
    	LjWriteLog(Self:cArqLog  + Self:cOrcamento + '.TXT', cMsg)
    Else 
    	LjWriteLog(Self:cArqLog + Self:cOrcamento + '.TXT', cMsg)  
    EndIf 	

 	RestArea(aArea)


Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | LiberarOrc      บAutor  ณVendas CRM           บ Data ณ  12/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que verifica se o orcamento pode ser finalizado (liberado)   บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LiberarOrc() Class LjClInFSAn     
	Local aArea := nil   //WorkArea atual
	Local lLibera := .F. //Orcamento liberado?

            
    aArea := GetArea()
 	
 	DbSelectArea("SL1")          
    
	lLibera := Empty(L1_IFSANST) .OR. RTrim(L1_IFSANST) == _L1_IFSANST_APROVADO

 	RestArea(aArea)


Return lLibera

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |ExibirFrm        บAutor  ณVendas CRM           บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que exibe a janela para digita็ao do numero do cupom e serie บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method ExibirFrm() Class LjClInFSAn
	Local oDlgAnalise := nil //Janela para informar a Observa็ใo da analise 
	Local cTexto := space(255)  //Texto da observacao da analise
	Local nOpc := 0     //Confirmacao do usuario
	Local lRet := .F.   //Confirmacao da janela


	DEFINE DIALOG oDlgAnalise TITLE STR0010 FROM 180,180 TO 305,700 PIXEL  //"Informe a observa็ใo a ser re-enviada ao financial" 
		
	
	    oTMultiget1 := TMultiget():New(05,05,{|u|if(Pcount()>0,cTexto:=u,cTexto)},;
	                           oDlgAnalise,250,42,,.F.,,,,.T.,,,,,,,,,,,.F.)   
	                                                      
	    SButton():New( 50,005,01,{|| nOpc := 1, oDlgAnalise:End()},oDlgAnalise,.T.,,)
	    SButton():New( 50,036,02,{||oDlgAnalise:End()},oDlgAnalise,.T.,,)
	       
	ACTIVATE DIALOG oDlgAnalise CENTERED 
	
	If nOpc == 1       
		
		Self:cObsAnalise := cTexto
		lRet := .T.
	EndIf

Return lRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | ReEnviarAna     บAutor  ณVendas CRM           บ Data ณ  06/03/2012 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza o re-envio da analise                            บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method ReEnviarAna() Class LjClInFSAn    
	Local lRet := .F. //Aprovacao de analise   
	
	If Self:ValidarApr(.T., STR0012, _L1_IFSANST_REPROVADO) .AND. Self:ExibirFrm()  //"re-enviar anแlise cr้dito"
		lRet := Self:EnviarAnal("R") //Executa o m้todo de envio da anแlise 
		Self:ExibirResp(.T.)
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |Destruct         บAutor  ณ Vendas CRM          บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que apaga o objeto                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method Destruct()  Class LjClInFSAn
	// Metodo indevido, nใo ้ possํvel o objeto destruir ele mesmo
	//FreeObj(Self)
	//Self := nil
Return Nil     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |Lj2502StPr       บAutor  ณ Vendas CRM          บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para configurar a variavel de processamento                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpL1 = Variavel de processamento                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj2502StPr(lValor)

	Default lValor := .T.

	lProcessa := lValor
	
Return lProcessa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |Lj2502StOp       บAutor  ณ Vendas CRM          บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para configurar a variavel de Operacao                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpC1 = Variavel de Operacao                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj2502StOp(cOpera) 

	Default cOpera := ""

	cOperac :=  cOpera                


Return cOperac

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |Lj2502StOb       บAutor  ณ Vendas CRM          บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para configurar a variavel de Observacao                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpC1 = Variavel de Operacao                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj2502StOb(cObs) 

	Default cObs := ""

	cObsAnalise := cObs 
	
Return cObsAnalise


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |Lj2502GtOp       บAutor  ณ Vendas CRM          บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar a variavel de Operacao                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj2502GtOp()  

Return cOperac    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |Lj2502GtOb       บAutor  ณ Vendas CRM          บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar a variavel de Observacao                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj2502GtOb()
  
Return cObsAnalise  
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |Lj2502GtPr       บAutor  ณ Vendas CRM          บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para obter a variavel de processamento                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj2502GtPr()

Return lProcessa  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |ProcResp         บAutor  ณ Vendas CRM          บ Data ณ  06/03/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo para processar a resposta EAI                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ProcResp(cXML) Class LjClInFSAn

		Local oXMLEAI  := Nil //Objeto EAI      
		Local lRet		:= .F. //lRetorno
		Local aMsgErr	:= {} //Mensagem de Erro
		Local aMsgWrn	:= {} //Mensagem de Warnning  
		Local cRotina	:= "LOJA701"
		Local oTag	:= Nil //Objeto das tags
		Local cOrcamento := "" //orcamento     
		Local cStatAnAtu := "" //Status da analise de credito         
		Local cMsgRet := ""    
		Local cMsg1 := ""
		Local cMsg := ""
  
		conout ( 'Inicio Processamento resposta EAI ' + FunName() + " " + cValtoChar( Time() ) ) 
		
		oXMLEAI := 	LjClXMLEai():New("ResponseMessage", , , , "AnaliseCredito", "ReturnContent" )
	 
		oXMLEAI:AddTag("RetailProposalRegister", "", 0,, , 1, "1","")  //Adiciona a tag pai		
		
		oTag := oXMLEAI:ReceberXML(cXML, @cMsgRet, @lRet, @aMsgErr, @aMsgWrn)
		
		If !lRet .AND. IsInCallStack(cRotina)  //e for o mesmo or็amento 
			Lj2502StPr(.T.) //Seta a variแvel de controle para sair do la็o
			oXMLEAI:ExibirResp(cMsgRet, aMsgErr, aMsgWrn) //Exibir a mensagem de retorno de erro do XML
		EndIf

		
		If lRet .and. Valtype(oTag) == "O"
		   
		   
			If ( XmlChildEx( oTag, "_ORDERNUMBER" ) <> NIL ) 
				cOrcamento := Alltrim(oTag:_OrderNumber:Text)
			Else
				lRet := .F.
				cMsgRet :=  STR0023 //"XML Invแlido"
			EndIf   

			If  XmlChildEx( oTag, "_PURCHASEAMOUNT" ) <> NIL 
				nValor := Val( Alltrim(oTag:_PurchaseAmount:Text) )
			Else
				lRet := .F.
				cMsgRet :=  STR0023 //"XML Invแlido"
			EndIf   
			
			If  XmlChildEx( oTag, "_ANALYSISSTATUS" ) <> NIL 
				cStatAna := Alltrim(oTag:_AnalysisStatus:Text)
			Else
				lRet := .F.
				cMsgRet :=  STR0023 //"XML Invแlido"
			EndIf    
			
			If  XmlChildEx( oTag, "_AUTHORIZATIONCODE" ) <> NIL  
				cAutAna := Alltrim(oTag:_AuthorizationCode:Text )
			Else
				lRet := .F.
				cMsgRet :=  STR0023 //"XML Invแlido"
			EndIf 
			
			If  XmlChildEx( oTag, "_MESSAGE1" ) <> NIL  
					cMsg1 := Alltrim( oTag:_Message1:Text  )
			Else
				lRet := .F.
				cMsgRet :=  STR0023 //"XML Invแlido"
			EndIf  
			
			If  XmlChildEx( oTag, "_MESSAGE2" ) <> NIL  
				cMsg := Alltrim(oTag:_Message2:Text  )
			Else
				lRet := .F.
				cMsgRet :=  STR0023 //"XML Invแlido"
			EndIf
													   												
			If lRet
				
				//L้ o XML e processa a resposta
				If IsInCallStack(cRotina)  //e for o mesmo or็amento 
							
					//Valida a chamada da rotina
					If Alltrim(cOrcamento) ==  AllTrim(SL1->L1_FILIAL+SL1->L1_NUM)   
					//Verificar se o orcamento nao foi aprovado manualmente
						Lj2502StPr(.T.) //Seta a variแvel de controle para sair do la็o
						cStatAnAtu := _L1_IFSANST_REPROVADO
						
						//Verifica se ้ possivel alterar o status da analise
						
						If Self:ValidarApr(.f.,STR0024,, @cMsgRet)  //"receber Retorno Anแlise"
						
							If nValor ==  SL1->L1_VALBRUT+SL1->L1_DESCONT 
							
								Do Case  

									Case RTrim(cStatAna) $ _L1_IFSANST_APROVADO + "#" + _L1_IFSANST_REPROVADO + "#" + _L1_IFSANST_MESA//1+"#"+"0"+#"+"2" 
										cStatAnAtu := RTrim(cStatAna)
									Otherwise
										cStatAnAtu := _L1_IFSANST_OFFLINE 
								EndcASE 
								
								lRet := .T.
								cMsgRet := STR0025  //"Orcamento atualizado"
								
							Else 
							   
								lRet := .F.
								cMsgRet := STR0026 + AllTrim(Transform(SL1->L1_FILIAL+SL1->L1_NUM, "@R 99999999999999.99999")) + STR0027 +  AllTrim(Transform(nValor, "@R 99999999999999.99999")) +"]"	//Valor Total do Bem ["	 ### + "] nใo confere com o Valor da Compra retornado [" ###			
								LjWriteLog(Self:cArqLog  + SL1->L1_NUM + '.TXT', cMsgRet)    
							
							EndIf
						
						Else 
						  
								lRet := .F.
						
						EndIf	
						
						Self:AtualizarS(cStatAnAtu, cMsg1, cMsg)	
						//Atualiza o status da analise							

					
					EndIf 
				Else
					lRet := .F.
					cMsgRet := STR0028 + oXMLEAI:cBReqOpera + STR0029 + cRotina //"Mensagem "##" deve ser processada em tempo de execu็ใo da rotina " ###
				EndIf
				
			Else
				lRet := .F.
				cMsgRet :=  STR0030 + cStatAna + "]" //"Status da Analise invalido ["
			EndIf

			  	
		Else
                lRet := .F. 
                cMsgRet := STR0031 //"XML nใo processado - Erro no retorno do XML enviado"
		EndIf   
		    
		If oTag <> Nil 
			FreeObj(oTag) 
			oTag := nil
		EndIf
	
		conout ( 'Final Processamento resposta EAI ' + FunName() + " " + cValtoChar( Time() ) )

		If oXMLEAI <> NIL  
			oXMLEAI:Destruct()
			FreeObj(oXMLEAI)
			oXMLEAI := NIL
		EndIf

Return 
