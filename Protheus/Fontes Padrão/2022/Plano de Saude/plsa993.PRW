#include "PLSA993.CH"  
#include "PLSMCCR.CH"  
#include "PLSMGER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA993
Reenvio de transacoes online

@author  PLS TEAM
@version P11
@since   29/08/16
/*/
//------------------------------------------------------------------- 
Function PLSA993

// Declaracao de variaveis...
PRIVATE aRotina     := MenuDef()
PRIVATE cCadastro 	:= STR0001//"Reenvio de transações de Autorização Online"

// Chama funcao de Browse... 
B0S->(mBrowse(06,01,22,75,"B0S"))

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} PlS993ENV
Reenvio de transacoes online

@author  PLS TEAM
@version P11
@since   29/08/16
/*/
//------------------------------------------------------------------- 
Function PlS993ENV()
Local aDados  := {}        
Local aItens  := {}  
Local aDadSeq := {}
Local aQuimio := {}
Local aRadio  := {}
Local aRetOln := {}         
Local cMsgXsdErr := ""

// Verifica tipo de transacao                
If B0S->B0S_ENVREC == "2"
    MsgInfo(STR0002)//"O reenvio de transações é permitido somente para transações do tipo 'Envio'"
    Return
EndIf

// Busca informacoes da B0T e monta array para realizar a conexao
aDadSeq := PlsGetB0T(B0S->B0S_NUMSEQ,B0S->B0S_TIPTRA,B0S->B0S_OPESOL,nil,B0S->B0S_NUMARQ)   
aDados  := aDadSeq[1] 
aItens  := aDadSeq[2]  
aQuimio := aDadSeq[3] 
aRadio  := aDadSeq[4] 

// Realiza conexao com a outra operadora
MsAguarde( {|| aRetOln := PlsPtuOln(aDados,aItens,AllTrim(B0S->B0S_NUMSEQ)+"R."+Subs(PLSINTPAD(),2,3),.F.,.F. ,nil,aQuimio,aRadio,@cMsgXsdErr) }, STR0007 , STR0008, .F.) //"Comunicando"### "Aguarde..."    

If !Empty(cMsgXsdErr)
	MsgInfo(STR0009+cMsgXsdErr)//"Erro: "  
ElseIf len(aRetOln) == 0
	MsgInfo(STR0010)//"Não foi possível realizar a comunicação."	
ElseIf len(aRetOln) > 0 .And. PlsPtuGet("CD_TRANS",aRetOln[1]) != "00310"
	MsgInfo(STR0004) //"Transação realizada."  
EndIf
	
Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional

@author  PLS TEAM
@version P11
@since   29/08/16
/*/
//------------------------------------------------------------------- 
Static Function MenuDef()
Private aRotina := { 	{ STRPL01	,'AxPesqui' , 0 ,K_Pesquisar	,0 ,.F.},; //"Pesquisar"
						{ STR0005	,'AxVisual' , 0  ,K_Visualizar	,0 ,Nil},; //"Visualizar"
						{ STR0006	,'PlS993ENV', 0 ,K_Alterar		,0 ,Nil}}  //"Reenviar"

Return(aRotina)
