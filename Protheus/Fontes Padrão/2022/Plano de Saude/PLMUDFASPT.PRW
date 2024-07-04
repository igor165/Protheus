#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER2.CH"
#INCLUDE "PLSMCCR.CH"
#include "TOPCONN.CH"     

#define  K_VisOnline  13
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLMUDFASPT ³ Autor ³ Microsiga           ³ Data ³ 05.08.15 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Faz a mudanca de fase em thread para PTU Online            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PLMUDFASPT(cEmp,cFil,nRecBCL,nRecAliCab,cAliasPri,cAliasCab,lAutori,aItensGlo,lReanaliza,lSolicit,lPagAto,cChaveLib,lGetCri,;
						 lProtoc,lRecGlo,nRecAliPri,nRecBCI,nRecBEA,aAreaBD6,nOpc,lReembolso,aAreaBE2,lCompSADT,cTipGui)   
						 
Local nValPag     := 0
Local cChaveBD5   := ""
Local cChaveBEA   := ""    
Default aAreaBE2  := {}
Default aAreaBD6  := {}    
Default lCompSADT := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa ambiente com base nos dados informados do PLSPTUROUT		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ               
lJob := .T.
RpcSetType ( 3 )
RpcSetEnv( cEmp, cFil,,,'PLS')    

BCL->(DbSetOrder(1))     
BCL->(DbGoTo(nRecBCL))         

BCI->(DbSetOrder(1))     
BCI->(DbGoTo(nRecBCI)) 

&(cAliasCab+"->(DbSetOrder(1))") 
&(cAliasCab+"->(DbGoTo("+Str(nRecAliCab)+"))")   

&(cAliasPri+"->(DbSetOrder(1))") 
&(cAliasPri+"->(DbGoTo("+Str(nRecAliPri)+"))")   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realizo a mudanca de fase da Guia de Complemento de SADT                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If lCompSADT
	PLSA500RFS("BD5",BD5->(RECNO()),nOpc,,.T.)
	PLSXMUDFAS("BD5","1","",cTipGui,dDataBase,.F.,"3")   
	   
	//Conout("PLMUDFASPT -> Mudanca de fase da guia "+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO)+" realizado com sucesso.") 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realizo a mudanca de fase de solicitacao SADT                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
Else

	Begin Transaction
	
	PLSXMUDFAS(cAliasPri,"1",BCL->BCL_CODOPE,BCL->BCL_TIPGUI,&(cAliasCab+"->"+cAliasCab+"_DATPRO"),lAutori,nil,nil,nil,.F.,aItensGlo,nil,lReanaliza,.F.,;
		  			 nil,nil,nil,nil,nil,nil,nil,lSolicit,Nil,lPagAto,cChaveLib,.F.,lGetCri, lProtoc,lRecGlo)
	
	If nOpc <> K_Visualizar .And. nOpc <> K_VisOnline
		If GetNewPar("MV_PLADPAG","0") == "1" .and. !lReembolso
			If nOpc <> K_Excluir
				PLS90CRDB(BEA->BEA_OPERDA,BEA->BEA_CODRDA,BEA->BEA_CODLDP,BEA->BEA_CODPEG,BEA->BEA_NUMGUI,;
						  BEA->BEA_OPEUSR,BEA->BEA_CODEMP,BEA->BEA_MATRIC,BEA->BEA_TIPREG,BEA->BEA_CONEMP,;
						  BEA->BEA_VERCON,GetNewPar("MV_PLCDADC","901"),nOpc)
			Else
				PLS90CRDB(BEA->BEA_OPERDA,BEA->BEA_CODRDA,BEA->BEA_CODLDP,BEA->BEA_CODPEG,BEA->BEA_NUMGUI,;
						  BEA->BEA_OPEUSR,BEA->BEA_CODEMP,BEA->BEA_MATRIC,BEA->BEA_TIPREG,BEA->BEA_CONEMP,;
				 		  BEA->BEA_VERCON,GetNewPar("MV_PLCDADD","900"),nOpc)
			EndIf
		EndIf
	Endif
	
	End Transaction
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica valor pago                         						     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	BEA->( DbGoTo(nRecBEA) )
		
	cChaveBD5 := BEA->(BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI)
	cChaveBEA := BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT)
	
	If BE2->(FieldPos("BE2_VLPGGU")) > 0
		BE2->(DbSetOrder(1))//BE2_FILIAL, BE2_OPEMOV, BE2_ANOAUT, BE2_MESAUT, BE2_NUMAUT, BE2_SEQUEN
		If BE2->(MsSeek(xFilial("BE2")+cChaveBEA))
			While ! BE2->(Eof()) .And. xFilial("BE2")+cChaveBEA == BE2->(BE2_FILIAL+BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT)
				BD6->(DbSetOrder(1))
				nValPag := 0
				If BD6->(MsSeek(xFilial("BD6")+cChaveBD5+BEA->BEA_ORIMOV+BE2->BE2_SEQUEN))
					nValPag := BD6->BD6_VLRPAG
					If len(aAreaBD6) > 0 
						Restarea(aAreaBD6)
					EndIf	
				EndIf
		
				If nValPag > 0
					BE2->(RecLock("BE2",.F.))
					BE2->BE2_VLPGGU := nValPag
					BE2->(MsUnLock())
				EndIf
				BE2->(DbSkip())
			EndDo   
			If len(aAreaBE2) > 0
				Restarea(aAreaBE2) 
			Endif	
		EndIf
	Endif  
	//Conout("PLMUDFASPT -> Mudanca de fase da guia "+cChaveBEA+" realizado com sucesso.")  
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha ambiente aberto                          						     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
RpcClearEnv()

Return