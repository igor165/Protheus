#INCLUDE "LOJA2508.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"   

#DEFINE 	_L1_IFSANST_APROVADO 	"1"
#DEFINE 	_L1_IFSANST_REPROVADO 	"0"
#DEFINE 	_L1_IFSANST_MESA 		"2"   
#DEFINE 	_L1_IFSANST_OFFLINE 	"9"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA2508   บAutor  ณMicrosiga          บ Data ณ  02/27/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para identificacao do fonte no repositorio.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function LOJA2508() ; Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCIFSRecMesa บAutor  ณProtheus        บ Data ณ  02/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Classe para realizar o tratamento de uma mensagem com      บฑฑ
ฑฑบ          ณ Anแlise de cr้dito realizada pelo Financial Service        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LJCIFSRecMesa()                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpO1 -> ObjXml contendo as Tags                           บฑฑ
ฑฑบ          ณ  - TotvsMessage                                            บฑฑ
ฑฑบ          ณ  - BusinessContent                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA2503                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Class LJCIFSRecMesa

	Data	oXml          // contem o objeto XML inicial
	Data	nAprovado     // Conteudo da Tag AnalysisStatus
	Data	cOrcamento    // Conteudo da Tag OrderNumber
	Data	cContFS       // Conteudo da Tag Contract
	Data	lValid        // atributo interno que indica a validacao dos dados = Orcamento Ok
	Data	cMsg1		  // mensagem com a explica็ใo da anแlise
	Data	cMsg2		  // mensagem para explica็ใo ao cliente 
	Data	nRetorno      // codigo a ser retornado para identificacao do processamento : 0 - nao realizado : 1 - executado
	Data	cMensagem     // descricao sobre o retorno do processamento
	
	Method	New()
	Method	Destruct()
	Method	Gravar()
	Method	GetNumRet()
	Method	GetMsgRet()
	Method	GetContrat()
	Method	ValidaOrc()
	Method	SetObjXml()
	
	// Metodos internos para processamento
	Method Iniciar()
	Method Preencher()

End Class

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณDestruct  บAutor  ณProtheus            บ Data ณ  02/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a instancia do objeto da classe                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LJCIFSRecMesa():Destruct() -> NIL                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ objeto da classe LJCIFSRecMesa                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Classe LJCIFSRecMesa                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Destruct() Class LJCIFSRecMesa

	If ( Self:oXml <> NIL )
		
		FreeObj( Self:oXml )
		Self:oXml := NIL
	EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNEW       บAutor  ณProtheus            บ Data ณ  02/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a instancia do objeto da classe                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LJCIFSRecMesa():New( ExpO1 ) -> Construtor                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ objeto da classe LJCIFSRecMesa                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpO1 -> ObjXml contendo as Tags                           บฑฑ
ฑฑบ          ณ  - TotvsMessage                                            บฑฑ
ฑฑบ          ณ  - BusinessRequest                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Classe LJCIFSRecMesa                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New( oObjXml ) Class LJCIFSRecMesa

	Self:Iniciar()
	
	If ( oObjXml <> NIL )
		
		Self:SetObjXml( oObjXml )
	EndIf

Return Self


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSetObjXml บAutor  ณProtheus            บ Data ณ  02/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a instancia do objeto da classe                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LJCIFSRecMesa():New( ExpO1 )                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ objeto da classe LJCIFSRecMesa                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpO1 -> ObjXml contendo as Tags                           บฑฑ
ฑฑบ          ณ  - TotvsMessage                                            บฑฑ
ฑฑบ          ณ  - BusinessRequest                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Classe LJCIFSRecMesa                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetObjXml( oObjXml ) Class LJCIFSRecMesa

	If ( oObjXml <> NIL )
		
		Self:oXml := oObjXml
		Self:Preencher()

	EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณIniciar   บAutor  ณProtheus            บ Data ณ  02/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicializa os atributos da classe com os valores           บฑฑ
ฑฑบ          ณ'default' conforme o tipo de variแvel.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LJCIFSRecMesa():Iniciar()                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ sem retorno                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Classe LJCIFSRecMesa                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Iniciar() Class LJCIFSRecMesa

	Self:oXml           := NIL
	Self:nAprovado      := 0
	Self:cOrcamento     := " "
	Self:cContFS        := " "
	Self:nRetorno       := 0
	Self:cMensagem      := " "
	Self:lValid	        := .F.
	Self:cMsg1          := " "
	Self:cMsg2          := " "

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณPreencher บAutor  ณProtheus            บ Data ณ  02/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Associa as tags do Xml aos atributos da classe             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LJCIFSRecMesa():Preencher()                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ sem retorno                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Classe LJCIFSRecMesa                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Preencher() Class LJCIFSRecMesa

	Local oXmlTemp := NIL		// Objeto Temporario do XML como atalho para o BusinessRequest e BusinessContent
	Local lXmlOper := .F.		// Identifica ser a operacao de "MESACREDITO"
	
	If ( ValType(Self:oXml) == "O" )
		
		If ( XmlChildEx( Self:oXml, "_TOTVSMESSAGE") <> NIL .AND. XmlChildEx( Self:oXml:_TotvsMessage, "_BUSINESSMESSAGE") <> NIL .AND. ;
			XmlChildEx( Self:oXml:_TotvsMessage:_BusinessMessage, "_BUSINESSREQUEST") <> NIL .AND.;
			XmlChildEx( Self:oXml:_TotvsMessage:_BusinessMessage:_BusinessRequest, "_OPERATION" ) <> NIL )
	
			oXmlTemp := Self:oXml:_TotvsMessage:_BusinessMessage:_BusinessRequest:_Operation
			
			If ( Upper(Alltrim(oXmlTemp:Text)) == "MESACREDITO" )
				
				lXmlOper := .T.
				
			Else
				
				Self:nRetorno := 0 
				Self:cMensagem  := STR0001  // "Opera็ใo diferente de 'MESACREDITO'" 
				
			EndIf
	
		EndIf
		// verifica a existencia das tags superiores ao BusinessContent
		If ( lXmlOper .AND. XmlChildEx( Self:oXml:_TotvsMessage:_BusinessMessage, "_BUSINESSCONTENT") <> NIL ) .AND. ;
		     XmlChildEx( Self:oXml:_TotvsMessage:_BusinessMessage:_BusinessContent, "_RETURNANALYSISSTATUS") <> NIL
			
			oXmlTemp := Self:oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReturnAnalysisStatus
	
			If ( XmlChildEx( oXmlTemp, "_CONTRACT" ) <> NIL )  // --> CONTRACT = contrato para o XML de retorno
				
				Self:cContFS := Alltrim(oXmlTemp:_Contract:Text)
				
			EndIf
			
			If ( XmlChildEx( oXmlTemp, "_ANALYSISSTATUS" ) <> NIL )  // --> AnalysisStatus = Aprovacao/Reprovacao do Orcamento
				
				Self:nAprovado := Val( Alltrim(oXmlTemp:_AnalysisStatus:Text) )
				
			EndIf
	
			If ( XmlChildEx( oXmlTemp, "_ORDERNUMBER" ) <> NIL )  // --> OrderNumber = Numero do Orcamento
				
				Self:cOrcamento := Alltrim(oXmlTemp:_OrderNumber:Text)
				
			EndIf

			If ( XmlChildEx( oXmlTemp, "_MESSAGE1" ) <> NIL )  // --> Message1 = Numero do Orcamento
				
				Self:cMsg1 := Alltrim(oXmlTemp:_Message1:Text)
				
			EndIf

			If ( XmlChildEx( oXmlTemp, "_MESSAGE2" ) <> NIL )  // --> Message2 = Numero do Orcamento
				
				Self:cMsg2 := Alltrim(oXmlTemp:_Message2:Text)
				
			EndIf
	
		EndIf
	Else

		Self:nRetorno   := 0
		Self:cMensagem	:= STR0002		// "XML nao pode ser identificado"

	EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณGetContrat บAutor  ณProtheus           บ Data ณ  02/28/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo para obter o numero do contrato vindo pelo XML      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LJCIFSRecMesa():GetContrat()                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ cRet --> Codigo do Or็amento                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Classe LJCIFSRecMesa                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetContrat() Class LJCIFSRecMesa

Return Self:cContFS

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณGetNumRet  บAutor  ณProtheus           บ Data ณ  02/28/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o resultado do metodo de validacao dos dados       บฑฑ
ฑฑบ          ณdo XML.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LJCIFSRecMesa():GetNumRet()                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ nRet --> Aprovacao                                         บฑฑ
ฑฑบ          ณ     0 = Orcamento nao alterado                             บฑฑ
ฑฑบ          ณ     1 = Orcamento atualizado                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Classe LJCIFSRecMesa                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNumRet() Class LJCIFSRecMesa

Return Self:nRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณGetMsgRet บAutor  ณProtheus            บ Data ณ  02/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o resultado do metodo de validacao dos dados       บฑฑ
ฑฑบ          ณdo XML.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LJCIFSRecMesa():GetMsgRet()                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ cMensagem = Descricao da mensagem de retorno para o EAI.   บฑฑ
ฑฑบ          ณ   Essa mensagem estara no XML de retorno.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Classe LJCIFSRecMesa                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetMsgRet() Class LJCIFSRecMesa

Return Self:cMensagem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบMetodo    ณValidaOrc บAutor  ณProtheus           บ Data ณ  02/28/12    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a consulta a tabela SL1 e verifica:                บฑฑ
ฑฑบ		     ณ  - a existencia do orcamento                               บฑฑ
ฑฑบ		     ณ  - a validade --> L1_DTLIM >= database                     บฑฑ
ฑฑบ          ณ  - seu status de aprovacao                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LJCIFSRecMesa():ValidaOrc()                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. = Orcamento Ok funcao de gravacao pode ser chamada     บฑฑ
ฑฑบ          ณ .F. = Orcamento                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Classe LJCIFSRecMesa                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method  ValidaOrc() Class LJCIFSRecMesa

	Local lOrcam 	:= .F.	                                         // indica se o Orcamento estแ Ok para processamento
	Local aSave		:= GetArea()                                    // guarda a area posicionada
	Local lSaveSL1 	:= ( Select("SL1")<>0 )                        // verifica se a tabela SL1 esta aberta
	Local aSaveSL1 	:= IIF( lSaveSL1, SL1->(GetArea()), {} )      // guarda o posicionamento especifico da tabela SL1
	
	//Verifica parโmetro que verifica se o modulo sigaloja esta integrado com o Financial Services
	Local lMvLjIntFS := GetRpoRelease("R5") .AND. SuperGetMV("MV_LJINTFS",,.F.) .AND. IIF(FindFunction("LjUpd90Ok"),LjUpd90Ok(),.F.) 
	
	DbSelectArea("SL1")
	SL1->(DbSetOrder(1))	// Ordem 1 ==> L1_FILIAL + L1_NUM
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ O resultado do DbSeek e a validade do Orcamento     ณ
	//ณ indicarao se ha necessidade de alteracao do registroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ( lMvLjIntFS .AND. SL1->( DbSeek( Self:cOrcamento) ) ) 
		
		// verifica o prazo de validade do orcamento
		If ( SL1->L1_DTLIM >= dDataBase )
			
			lOrcam := .T.
			
		Else
			
			lOrcam := .F.
			Self:nRetorno := 0
			Self:cMensagem := STR0003	// "Or็amento fora do prazo validade"
			
		EndIf
	Else

		lOrcam := .F.
		Self:nRetorno := 0
		
		If ( !lMvLjIntFS ) 
			
			Self:cMensagem := STR0004	// "Integra็ใo Protheus e Financial Service nใo habilitada"
			
		Else
			
			Self:cMensagem := STR0005	// "Or็amento nใo localizado"
			
		EndIf
	EndIf
	
	// restaura a area salva da tabela SL1 
	If ( lSaveSL1 .AND. Len(aSaveSL1) > 0 )
		
		RestArea( aSaveSL1 )
		
	EndIf
	
	RestArea( aSave )
	
	Self:lValid := lOrcam

Return lOrcam

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบMetodo    ณGravar    บAutor  ณProtheus           บ Data ณ  02/28/12    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo para realizar a gravacao dos dados do XML na tabela บฑฑ
ฑฑบ          ณ SL1 - Or็amento  :: L1_IFSANST => 0 || 1                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LJCIFSRecMesa():Gravar()                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. = Or็amento alterado com sucesso                       บฑฑ
ฑฑบ          ณ .F. = Or็amento nใo alterado                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Classe LJCIFSRecMesa                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method Gravar() Class LJCIFSRecMesa

	Local lGrava	:= .F.	                                        // tera conteudo de retorno da fun็ใo com sinalizacao da grava็ใo
	Local aSave		:= GetArea() 									// guarda a area posicionada
	Local lSaveSL1	:= ( Select("SL1")<>0 )  						// verifica se a tabela SL1 esta aberta para guardar  o posicionamento
	Local aSaveSL1 	:= IIF( lSaveSL1, SL1->(GetArea()), {} )  	// guarda o posicionamento especifico da tabela SL1
	Local cAuxStat 	:= " "										    // recebera o valor aprovado/reprovado para retorno do Xml
	Local cAuxFlag 	:= _L1_IFSANST_MESA 										    // valor do flag para gravacao do campo
	Local cAntMsg1	:= " "										    // armazena o conte๚do do Campo MEMO para a Mensagem 1
	Local cAntMsg2	:= " "										    // armazena o conte๚do do Campo MEMO para a Mensagem 2
	
	// Verifica os dados Orcamento e a existencia do Orcamento 
	If ( Self:lValid .AND. SL1->(DbSeek( Self:cOrcamento ) ) )
		
		If ( SL1->L1_IFSANST <> cAuxFlag .OR. !Empty(SL1->L1_USRST) )
			
			lGrava := .F.
			Self:nRetorno := 0
			
			// avalia se foi aprovado ou reprovado
			If ( SL1->L1_IFSANST == _L1_IFSANST_REPROVADO ) //0
				
				cAuxStat := STR0006	// "reprovado"
			ElseIf ( SL1->L1_IFSANST == _L1_IFSANST_APROVADO ) //1
				
				cAuxStat := STR0007	// "aprovado"
			Else
				
				cAuxStat := STR0008	// "avaliado"
			EndIf
			
			// monta a mensagem de retorno que estara no XML
			If !Empty(cAuxStat) .AND. !Empty(SL1->L1_USRST)
				
				Self:cMensagem := STR0009 + cAuxStat + STR0010 + SL1->L1_USRST	// "Or็amento " #### " manualmente pelo usuแrio " ####
			Else
				
				Self:cMensagem := STR0011 + cAuxStat + STR0012		// "Or็amento jแ " #### " anteriormente"
			EndIf
		Else
			
			lGrava := .T.
			Self:nRetorno := 1
			
			If ( Self:nAprovado == 1 )
				
				cAuxFlag := _L1_IFSANST_APROVADO //1
			ElseIf ( Self:nAprovado == 0 )
				
				cAuxFlag := _L1_IFSANST_REPROVADO//2
			EndIf
			
			// realiza a alteracao do Status do Orcamento -> L1_IFSANST
			Reclock( "SL1", .F.)
			
			REPLACE L1_IFSANST WITH cAuxFlag
			
			SL1->(MsUnlock())
			
			// Recebe o conte๚do atual dos campos Memo para as Mensagens 1 e 2
			If !Empty(L1_IFSCDM1)
				
				cAntMsg1 := AllTrim(MSMM(L1_IFSCDM1,255))
			EndIf 
			
			If !Empty(L1_IFSCDM2)
			
				cAntMsg2 := AllTrim(MSMM(L1_IFSCDM2,255))
			EndIf

			// Grava็ใo das Mensagens ( 1 e 2 ) Campos MEMO			
			// verifica a exist๊ncia de conte๚do para exibi็ใo alterar ou incluir o novo conte๚do da Mensagem 1
			If !Empty(Self:cMsg1) .AND. !(cAntMsg1 == Self:cMsg1) 
			
				MSMM( L1_IFSCDM1, 255 , NIL, Self:cMsg1, 1, NIL , NIL, "SL1", "L1_IFSCDM1" ) 
			
			ElseIf Empty(Self:cMsg1) .AND. !Empty(cAntMsg1) 
			
				MSMM( L1_IFSCDM1, 255 , NIL, Self:cMsg1, 2 , NIL , NIL, "SL1" , "L1_IFSCDM1" ) 
			
			EndIf

			// verifica a exist๊ncia de conte๚do para exibi็ใo alterar ou incluir o novo conte๚doda Mensagem 2			
			If !Empty(Self:cMsg2) .AND. !(cAntMsg2 == Self:cMsg2) 
			
				MSMM( L1_IFSCDM2, 255 , NIL, Self:cMsg2, 1, NIL, NIL, "SL1", "L1_IFSCDM2" )
			
			ElseIf Empty(Self:cMsg2) .AND. !Empty(cAntMsg2)
			
				MSMM( L1_IFSCDM2, 255 , NIL, Self:cMsg2, 2, NIL, NIL, "SL1", "L1_IFSCDM2" ) 
			
			EndIf

		EndIf
	Else
		
		Self:ValidaOrc()
		If Self:lValid
			lGrava := Self:Gravar() 
		EndIf
		
	EndIf
	
	If ( lSaveSl1 .AND. Len(aSaveSL1)>0 )
		RestArea( aSaveSL1 )
	EndIf
	
	RestArea( aSave )

Return lGrava