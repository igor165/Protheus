#Include "CTBA230.Ch"
#Include "PROTHEUS.Ch"
#Include  "FONT.CH"
#Include  "COLORS.CH"

STATIC __lBlind := IsBlind()
Static lFWCodFil := FindFunction("FWCodFil")
Static lDefTopCTB   := IfDefTopCTB()
Static _nQtdEntid	:= CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
Static lCtbIsCube := FindFunction("CtbIsCube")
Static __oTempTable
Static __oTmpTbNewEnt

//-------------------------------------------------------------------
/*{Protheus.doc} Ctba230
Aglutina‡„o de dados Configurada. (Modelo B) 

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function Ctba230(lBat)

Local cCadastro:= STR0001  		//"Consolida‡„o de Empresas / Filiais"

Local cMensagem:= ""

Local nOpca
Local aSays 		:= {}
Local aButtons		:= {}


DEFAULT lBat	:= .F.

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

If Ctb240Emp() //Se estiver na empresa/filial DESTINO (de acordo com o param. MV_CONSOLD
	If __lBlind .Or. lBat
		BatchProcess( 	cCadastro, 	STR0009 + Chr(13) + Chr(10) +;
			STR0010, "CTB230",;
			{ || Ct230Proc(.T.) },;
			{ || .F. })
		Return .T.
	Endif
	
	// Mostra tela de aviso - processar exclusivo			        
	cMensagem := STR0004+chr(13)  		//"E' melhor que os arquivos associados a"
	cMensagem += STR0005+chr(13)  		//"esta rotina nao  estejam  em  uso  por"
	cMensagem += STR0006+chr(13)  		//"outras esta‡”es."
	cMensagem += STR0007+chr(13)  		//"Fa‡a com que os outros usu rios saiam do"
	cMensagem += STR0008+chr(13)  		//"sistema."
	IF !MsgYesNo(cMensagem,STR0009)		//"ATEN€ŽO"
		Return
	Endif
	
	// Variaveis utilizadas para parametros                         
	// mv_par01     // Cod. Roteiro Consolidacao                    
	// mv_par02     // da data                                      
	// mv_par03     // Ate a data                                   
	// mv_par04     // Apaga? Periodo/Tudo                   		 
	// mv_par05     // Escolhe Moeda?                               
	// mv_par06     // Qual Moeda?                                  
	
	Pergunte("CTB230",.f.)
	AADD(aSays,STR0009 )	//Este programa tem como objetivo aglutinar os saldos conforme configurado
	AADD(aSays,STR0010 )	//pelo usuario na Rotina de Consolidacao.
	AADD(aSays,STR0011 )	//
	
	AADD(aButtons, { 5,.T.,{|| Pergunte("CTB230",.T. ) } })
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CtbOk(), FechaBatch(), nOpca:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons,, 160 )
	
	IF nOpca == 1
		If !CTBSerialI("CTBPROC","OFF")
			Return
		Endif
		Processa({|lEnd| CT230Proc()})
		CTBSerialF("CTBPROC","OFF")
	Endif
Endif


Return 

//-------------------------------------------------------------------
/*{Protheus.doc} Ct230Proc
Inicia o processamento dos arquivos de consolidacao

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ct230Proc(lBat)

Local lRet 		:= .T.
Local cCodigo 	:= mv_par01 //Codigo do Roteiro de Consolidacao
Local cEmpOri 	:= ""
Local cFilOri 	:= ""                  
Local cOrdem  	:= ""
Local dDataIni	:= mv_par02
Local dDataFim	:= mv_par03                                                          
Local nMoedas 	:= 0
Local cMoeda 		:= ""                      
Local nRegTotal 	:= 0
Local nRegCT1  	:= 0
Local nRegCTT  	:= 0
Local nRegCTD   	:= 0
Local nRegCTH   	:= 0
Local aCampos   	:= {}
Local cCpoDebito	:= ""
Local cCpoCredito	:= ""
Local cCpoChDeb	:= ""
Local cCpoChCre	:= ""
Local nX
Local aCpoChDeb := {}
Local aCpoChCre := {}

Local aAlias 	:= {}
Local cChave   := ""
Local cQuery	:= ""
Local nMax		:= 0
Local i

DEFAULT lBat	:= .F.

If mv_par05 == 2						// Considera Moeda Especifica
	aCtbMoeda  	:= CtbMoeda(mv_par06)
	If Empty(aCtbMoeda[1])                       
   	   Help(" ",1,"NOMOEDA")
	   TRB->(DbCloseArea())
	   Return .F.
	EndIf
	nMoedas  := 1
	cMoeda := aCtbMoeda[1]
Else
	nMoedas := __nQuantas
Endif


// VALIDACAO DE AMARRAÇÕES E BLOQUEIOS DE MOEDA/CALENDARIO
If CtVlDTMoed(dDataIni,dDataFim,mv_par05,mv_par06)
	// Se houver moeda, data ou data em moeda com status bloqueado.
	Return .F.
EndIf

If	!(	MA280FLock("CT1") .And.;
		MA280FLock("CT2") .And.;
		MA280FLock("CQ0") .And.;
		MA280FLock("CQ1") .And.;
		MA280FLock("CQ2") .And.;
		MA280FLock("CQ3") .And.;
		MA280FLock("CQ4") .And.;
		MA280FLock("CQ5") .And.;
		MA280FLock("CQ6") .And.;
		MA280FLock("CQ7") .And.;
		MA280FLock("CQ8") .And.;
		MA280FLock("CQ9") .And.;
		MA280FLock("CTC") .And.;
		MA280FLock("CTD") .And.;
		MA280FLock("CTF") .And.;
		MA280FLock("CTH") .And.;
		MA280FLock("CTB") .And.;
		MA280FLock("CTT") .And.;
		MA280FLock("CVX") .And.;
		MA280FLock("CVY") )

	// Fecha todos os arquivos e reabre-os de forma compartilhada   
	dbCloseAll()
	OpenFile(SubStr(cNumEmp,1,2))
	Return .T.
Else
	aAlias := {"CT2","CQ0","CQ1","CQ2","CQ3","CQ4","CQ5","CQ6","CQ7","CQ8","CQ9","CTC","CTF","CVX","CVY"}
	
	If mv_par04 == 2					// Apaga os arquivos
		For i := 1 to Len(aAlias)
			nMax := (aAlias[i])->(LastRec())
			cQuery := "DELETE FROM "+RetSqlName(aAlias[i])
			cQuery += " WHERE "
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa a string de execucao no banco para os proximos 1024 registro a fim de nao estourar o log do SGBD³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 To nMax STEP 1024
				cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+1023,10,0)+""
				TcSqlExec(cQuery+cChave)
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A tabela eh fechada para restaurar o buffer da aplicacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(aAlias[i])
			dbCloseArea()
			ChkFile(aAlias[i],.F.)
		Next
		
		DbCloseAll()
		OpenFile(SubStr(cNumEmp,1,2))
	Else						// Zera somente o periodo informado
		
		//Zera valores de saldos no periodo a consolidar
		Ct230Apaga(aAlias)
	EndIf
EndIf

// Verifica numero de decimais.                                 
aTam := TamSx3("CT2_VALOR")
nTamanho  := aTam[1]
nDecimais := aTam[2]


aCampos		:= {{"DTSALDO","D",8,0},;
  				 {"CONTA","C",Len(CriaVar("CT1_CONTA")),0},;				 		 
				 {"CUSTO","C",Len(CriaVar("CTT_CUSTO")),0},;
				 {"ITEM","C",Len(CriaVar("CTD_ITEM")),0},;						 
 				 {"CLVL","C",Len(CriaVar("CTH_CLVL")),0},;						 
 				 {"DEBITO","N",nTamanho,nDecimais},;						 
 				 {"CREDITO","N",nTamanho,nDecimais},;						         
 				 {"MOEDA","C",Len(CriaVar("CQ0_MOEDA")),0},;						 
 				 {"TPSALDO","C",Len(CriaVar("CQ0_TPSALD")),0}}

If __oTempTable <> Nil
	__oTempTable:Delete()
	__oTempTable := Nil
Endif

__oTempTable := FWTemporaryTable():New( "TRB" )  
__oTempTable:SetFields(aCampos) 
__oTempTable:AddIndex("1", {"DTSALDO","CONTA","CUSTO","ITEM","CLVL","MOEDA","TPSALDO"})
__oTempTable:AddIndex("2", {"MOEDA","TPSALDO","CONTA","CUSTO","ITEM","CLVL","DTSALDO"})

//------------------
//Criação da tabela temporaria
//------------------
__oTempTable:Create()  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo temporario NOVAS ENTIDADES³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {}
cCpoChave := "" 

AADD(aCampos,{"CT2_MOEDLC"	,"C",TamSx3('CT2_MOEDLC')[1],0}) 
AADD(aCampos,{"CT2_DATA" 	,"D",8,0})
AADD(aCampos,{"CT2_TPSALD"	,"C",TamSx3('CT2_TPSALD')[1],0})  
AADD(aCampos,{"CT2_DC"		,"C",TamSx3('CT2_DC')[1],0})  
AADD(aCampos,{"CT2_VALOR"	,"N",TamSx3('CT2_VALOR')[1],TamSx3('CT2_VALOR')[2]}) 
AADD(aCampos,{"CT2_DEBITO"	,"C",TamSx3('CT2_DEBITO')[1],TamSx3('CT2_DEBITO')[2]})  
AADD(aCampos,{"CT2_CREDIT"	,"C",TamSx3('CT2_CREDIT')[1],TamSx3('CT2_CREDIT')[2]})  
AADD(aCampos,{"CT2_CCD"		,"C",TamSx3('CT2_CCD')[1],TamSx3('CT2_CCD')[2]})  
AADD(aCampos,{"CT2_CCC"		,"C",TamSx3('CT2_CCC')[1],TamSx3('CT2_CCC')[2]})  
AADD(aCampos,{"CT2_ITEMD"	,"C",TamSx3('CT2_ITEMD')[1],TamSx3('CT2_ITEMD')[2]}) 
AADD(aCampos,{"CT2_ITEMC"	,"C",TamSx3('CT2_ITEMC')[1],TamSx3('CT2_ITEMC')[2]}) 
AADD(aCampos,{"CT2_CLVLDB"	,"C",TamSx3('CT2_CLVLDB')[1],TamSx3('CT2_CLVLDB')[2]}) 
AADD(aCampos,{"CT2_CLVLCR"	,"C",TamSx3('CT2_CLVLCR')[1],TamSx3('CT2_CLVLCR')[2]}) 

//Arrays para montagem dos indices na TRB2
aCpoChDeb   := {"CT2_MOEDLC","CT2_DATA","CT2_TPSALD","CT2_DC","CT2_DEBITO","CT2_CCD","CT2_ITEMD","CT2_CLVLDB"}
aCpoChCre   := {"CT2_MOEDLC","CT2_DATA","CT2_TPSALD","CT2_DC","CT2_CREDIT","CT2_CCC","CT2_ITEMC","CT2_CLVLCR"}

For nX:=5 To _nQtdEntid 

	cCpoDebito	:= "CT2_EC"+StrZero(nX,2)+"DB"
	cCpoCredito	:= "CT2_EC"+StrZero(nX,2)+"CR"
	AADD(aCampos,{cCpoDebito	,"C",TamSx3(cCpoDebito)[1],0})  
	AADD(aCampos,{cCpoCredito	,"C",TamSx3(cCpoCredito)[1],0}) 	
	
	AADD(aCpoChDeb,{cCpoDebito}) 
	AADD(aCpoChCre,{cCpoCredito}) 
		
Next nX

If __oTmpTbNewEnt <> Nil
	__oTmpTbNewEnt:Delete()
	__oTmpTbNewEnt := Nil
Endif
	
__oTmpTbNewEnt := FWTemporaryTable():New( "TRB2" )  
__oTmpTbNewEnt:SetFields(aCampos) 
__oTmpTbNewEnt:AddIndex("1", aCpoChDeb) //³Indice Debito³
__oTmpTbNewEnt:AddIndex("2", aCpoChCre) //³Indice Credito³

//------------------
//Criação da tabela temporaria
//------------------
__oTmpTbNewEnt:Create() 

dbSelectArea("TRB2")    
dbSetOrder(1)

dbSelectArea("TRB")
dbSetOrder(1)

nRegCT1	  := CT1->(RecCount())
nRegCTD	  := CTD->(RecCount())
nRegCTH	  := CTH->(RecCount())
nRegCTT	  := CTT->(RecCount())

nRegTotal := nRegCT1+nRegCTD+nRegCTh+nRegCTT

If ! lBat
	ProcRegua(nRegTotal)
Endif
	
dbSelectArea("CTB")               
dbSetOrder(2)
dbSeek(xFilial("CTB")+cCodigo)
If Found()                        	
	While !Eof() .And. CTB->CTB_CODIGO == cCodigo
		// Abre SX2 das Empresas Selecionadas - Se elemento em bco -> empresa ja foi aberta
		// anteriormente                         
		Ct230Open(CTB->CTB_EMPORI)
		cFilX		:= CTB->CTB_FILORI
		cEmpOri 	:= CTB->CTB_EMPORI
		cFilOri	:= CTB->CTB_FILORI
		cOrdem  	:= CTB->CTB_ORDEM

		While !Eof() .And. 	CTB->CTB_CODIGO == cCodigo .And. CTB->CTB_ORDEM == cOrdem 	.And.;
						 	CTB->CTB_EMPORI == cEmpOri .And. CTB->CTB_FILORI == cFilOri
			Ct230RCons(dDataIni,dDataFim,cMoeda,nMoedas,cCodigo,cFilX)	

			If !lRet
				Exit
			EndIf	
					
			dbSelectArea("CTB")
			cEmpOri	:= CTB->CTB_EMPORI
			cFilOri	:= CTB->CTB_FILORI
			cOrdem		:= CTB->CTB_ORDEM	
			dbSkip()
		End         
	End	            
	Ct230Saldo("CT1",1)			
	Ct230Saldo("CTT",1)
	Ct230Saldo("CTD",1)
	Ct230Saldo("CTH",1)
	
	aTpSld  := CtbRetaSLD()
	For nX := 1 to Len(aTpSld)
		Ctb230CQ8(aTpSld[nX],cFilAnt,dDataIni,dDataFim)
	Next nX
	If lCtbIsCube .And. CtbIsCube()
		Ct230SldEnt()
	EndIf
Endif

DbSelectArea("CT1")

If Select("TRB") > 0
	DbSelectArea("TRB")
	TRB->(DbCloseArea())
Endif

If Select("TRB2") > 0
	DbSelectArea("TRB2")
	TRB2->(DbCloseArea())
Endif

If __oTempTable <> Nil
	__oTempTable:Delete()
	__oTempTable := Nil
Endif

If __oTmpTbNewEnt <> Nil
	__oTmpTbNewEnt:Delete()
	__oTmpTbNewEnt := Nil
Endif

Return

//-------------------------------------------------------------------
/*{Protheus.doc} Ct230Saldo
Gera Registro de arquivo de Saldo   

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ct230Saldo(cArqBase,nOrder)

Local aSaveArea		:= GetArea()         
Local dDtInicial		:= CTOD("")
Local nAtuDebAnt		:= 0
Local nAtuCrdAnt		:= 0
Local nVlAtuDeb		:= 0 
Local nVlAtuCrd		:= 0
Local nSlDebAnt		:= 0
Local nSlCrdAnt		:= 0
Local cChave			:= ""
Local lOk				:= .F.
LocaL cChave1			:= ""
LocaL cChave1Ant		:= ""
Local aArq				:= {}		
Local nX				:= 0
Local dSaldo			:= CTOD("") 
Local cAlias			:= ""

If cArqBase $ "CT1"
	cArqBase := "CT1"
	dbSelectArea("CQ0")
	dbSelectArea("CQ1")
	aAdd(aArq,"CQ0")
	aAdd(aArq,"CQ1")
ElseIf cArqBase $ "CTT"
	cArqBase := "CTT"
	dbSelectArea("CQ2")
	dbSelectArea("CQ3")
	aAdd(aArq,"CQ2")
	aAdd(aArq,"CQ3")
ElseIf cArqBase $ "CTD"
	cArqBase := "CTD"
	dbSelectArea("CQ4")
	dbSelectArea("CQ5")
	aAdd(aArq,"CQ4")
	aAdd(aArq,"CQ5")
ElseIf cArqBase $ "CTH"
	cArqBase := "CTH"
	dbSelectArea("CQ6")
	dbSelectArea("CQ7")
	aAdd(aArq,"CQ6")
	aAdd(aArq,"CQ7")
EndIf

dbSelectArea("TRB")
dbSetOrder(2) 
dbGotop()          

While TRB->(!Eof())
	For nX:= 1 to Len(aArq)
	
		cAlias := aArq[nX]
	
		If nX == 1 // Mensal
			dSaldo := LastDay(TRB->DTSALDO)
		Else //Diario
			dSaldo := TRB->DTSALDO
		EndIf
		
		If cArqBase == "CT1" .And. !Empty(TRB->CONTA) .And. Empty(TRB->CUSTO) .And. Empty(TRB->ITEM).And. Empty(TRB->CLVL)		     
			cChave	:= DTOS(dSaldo)+TRB->CONTA+TRB->MOEDA+TRB->TPSALDO
			lOk 	:= .T.
		ElseIf cArqBase == "CTT" .And. !Empty(TRB->CUSTO) .And. Empty(TRB->ITEM).And. Empty(TRB->CLVL)		             
			cChave	:= DTOS(dSaldo)+TRB->CUSTO+TRB->CONTA+TRB->MOEDA+TRB->TPSALDO
			lOk 	:= .T.
		ElseIf cArqBase == "CTD" .And. !Empty(TRB->ITEM) .And. Empty(TRB->CLVL)
			cChave	:= DTOS(dSaldo)+TRB->ITEM+TRB->CUSTO+TRB->CONTA+TRB->MOEDA+TRB->TPSALDO 
			lOk 	:= .T.
		ElseIf cArqBase == "CTH" .And. !Empty(TRB->CLVL)
			cChave	:= DTOS(dSaldo)+TRB->CLVL+TRB->ITEM+TRB->CUSTO+TRB->CONTA+TRB->MOEDA+TRB->TPSALDO 
			lOk 	:= .T.
		Endif
		cChave1 := TRB->MOEDA+TRB->TPSALDO+TRB->CONTA+TRB->CUSTO+TRB->ITEM+TRB->CLVL
		
		If lOk
			dbSelectArea(cAlias)
			dbSetOrder(nOrder)
			lGrava := !(DbSeek(xFilial(cAlias)+cChave,.T.))
			Reclock(cAlias,lGrava)			
			If cArqBase == "CTT"
				&(cAlias + "_CCUSTO") := TRB->CUSTO
			ElseIf cArqBase == "CTD"
				&(cAlias + "_CCUSTO") := TRB->CUSTO
				&(cAlias + "_ITEM")	 := TRB->ITEM
			ElseIf cArqBase == "CTH"
				&(cAlias + "_CCUSTO") := TRB->CUSTO
				&(cAlias + "_ITEM")	 := TRB->ITEM
				&(cAlias + "_CLVL")	 := TRB->CLVL
			Endif
			
			&(cAlias + "_FILIAL") := xFilial(cAlias)
			&(cAlias + "_CONTA")  := TRB->CONTA
			&(cAlias + "_DATA")   := dSaldo
			&(cAlias + "_MOEDA")  := TRB->MOEDA
			&(cAlias + "_TPSALD") := TRB->TPSALDO
			&(cAlias + "_DEBITO") := TRB->DEBITO
			&(cAlias + "_CREDIT") := TRB->CREDITO
			MsUnlock()
		Endif
		dbSelectArea("TRB")
		lOk := .F.
		cChave1Ant := TRB->MOEDA+TRB->TPSALDO+TRB->CONTA+TRB->CUSTO+TRB->ITEM+TRB->CLVL
	Next nX
	TRB->(dbSkip())
End

                          
RestArea(aSaveArea)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct230Ok   ³ Autor  ³ Simone Mie Sato         ³ Data 10.07.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Confirma processamento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct230Ok()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Mensagem para confirmacao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct230OK()

Local cMensagem
Local cCodEmp	:= FWGRPCompany()
Local cNomeEmp := FWFilialName(cEmpAnt,cFilAnt,2)
Local cCodFil	:= IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Local cNomeFil	:= FWFilialName(cEmpAnt,cFilAnt,1)
 
If mv_par01 == 1
	cMensagem := STR0012+chr(13)		//"Os dados da empresa abaixo serao apagados"
	cMensagem += STR0002+cCodEmp+"-"+cNomeEmp+chr(13) //"Empresa : "
	cMensagem += STR0003+cCodFil+"-"+cNomeFil+chr(13)//"Filial  : "
	cMensagem += STR0013				//"Confirma Consolidacao nesta empresa?"
Else
	cMensagem := STR0013+chr(13)  //"Confirma Consolidacao nesta empresa?"
	cMensagem += STR0002+cCodEmp+"-"+cNomeEmp+chr(13) //"Empresa : "
	cMensagem += STR0003+cCodFil+"-"+cNomeFil        //"Filial : "
EndIf

Return MsgYesNo(cMensagem,STR0009)  //"Aten‡„o"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct230Open ³ Autor  ³ Simone Mie Sato         ³ Data 10.07.01³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Abre arquivo do SX2                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct230Open(cEmpresa)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ExpC1 = Codigo da Empresa                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct230Open(cEmpresa)

If Select("__SX2") <> 0
	dbSelectArea("__SX2")
	dbCloseArea()
EndIf	

OpenSxs(,,,,cEmpresa,"__SX2","SX2",,.F.)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct230Alias³ Autor  ³ Simone Mie Sato         ³ Data 10.07.01³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Abre arquivo origem                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct230Alias(cAlias,cModoSX2,cArquivo)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ExpC1 = Alias do arquivo                                    ³±±
±±³           ³ExpC2 = Modo de acesso                                      ³±±
±±³           ³ExpC3 = Nome do arquivo                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct230Alias(cAlias,cModoSX2,cArquivo,cModoEmp,cModoUni,cEmpP)

Local lRet := .T.

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Seleciona o arquivo a ser processado ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cModoEmp := FWModeAccess(cAlias,1,cEmpP)//X2_MODOEMP
cModoUni := FWModeAccess(cAlias,2,cEmpP)//X2_MODOUN
cModoSX2 := FWModeAccess(cAlias,3,cEmpP)//X2_MOD

dbSelectArea("__SX2")
dbSetOrder(1)
If dbSeek(cAlias)
	cArquivo := RetArq(__cRdd,Trim(RetFullName(cAlias,cEmpP)),.T.)
EndIf

Return lRet	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct230Apaga³ Autor  ³ Simone Mie Sato         ³ Data 10.07.01³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Apaga periodo desejado                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct230Apaga()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct230Apaga(aAlias)

Local dDataIni := mv_par02
Local dDataFim := mv_par03
Local cChave	:= ""
Local cQuery	:= ""
Local Ct220Del	:= ""
Local nCountReg:= 0
Local nMax		:= 0
Local nMin		:= 0
Local i

For i := 1 to Len(aAlias)
	
	dbSelectArea(aAlias[i])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual eh o maior e o menor Recno que satisfaca a selecao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Ct220Del	:= "Ct220Del"
	
	cQuery := "SELECT R_E_C_N_O_ RECNO "
	cQuery += "FROM "+RetSqlName(aAlias[i])
	cQuery += " WHERE " +aAlias[i]+"_FILIAL = '" + xFilial(aAlias[i])+"' AND "
	cQuery += aAlias[i]+"_DATA >= '" + DTOS(dDataIni)+ "' AND "
	cQuery += aAlias[i]+"_DATA <= '" + DTOS(dDataFim)+ "' AND "
	cQuery += " D_E_L_E_T_= ' '"
	cQuery += " ORDER BY RECNO"
	
	cQuery := ChangeQuery(cQuery)
	
	If ( Select ( "Ct220Del" ) <> 0 )
		dbSelectArea ( "Ct220Del" )
		dbCloseArea ()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),Ct220Del)
	
	dbSelectArea(aAlias[i])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a string de execucao no banco³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "DELETE FROM "+RetSqlName(aAlias[i])
	cQuery += " WHERE " + aAlias[i]+"_FILIAL = '" + xFilial(aAlias[i])+"' AND "
	cQuery += aAlias[i]+"_DATA >= '" + DTOS(dDataIni)+ "' AND "
	cQuery += aAlias[i]+"_DATA <= '" + DTOS(dDataFim)+ "' AND "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a string de execucao no banco para os proximos 1024 registro a fim de nao estourar o log do SGBD³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While Ct220Del->(!Eof())
		
		nMin := (Ct220Del)->RECNO
		
		nCountReg := 0
		
		While Ct220Del->(!Eof()) .and. nCountReg <= 4096
			
			nMax := (Ct220Del)->RECNO
			nCountReg++
			Ct220Del->(DbSkip())
			
		End
		
		cChave := "R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
		TcSqlExec(cQuery+cChave)
		
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A tabela eh fechada para restaurar o buffer da aplicacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(aAlias[i])
	dbCloseArea()
	ChkFile(aAlias[i],.F.)
Next



Return
//-------------------------------------------------------------------
/*{Protheus.doc} Ct230RCons
Aglutinacao dos Ct230RCons de acordo com o rot. consolidacao. 

@author Alvaro Camillo Neto

@param dDataIni 	Data Inicial                      
@param dDataFim 	Data Final                        
@param cMoeda 	Moeda                             
@param nMoedas 	Numero de Moedas                  
@param cCodigo 	Codigo da Empresa                 
@param cFilx 		Codigo da Filial                  
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ct230RCons(dDataIni,dDataFim,cMoeda,nMoedas,cCodigo,cFilx)

Local aSaveArea 		:= GetArea()
Local aSaldoCta 		:=	{}
Local aSaldoItem		:=	{}
Local aSaldoCC		:=	{}
Local aSaldoClVl		:=	{}
Local lConta 			:= .F.
Local lCusto			:= .F.
Local lItem			:= .F.
Local lClasse			:= .F.
Local dDataAtu 		:= CTOD("")
Local cModoSX2 		:= ""
Local cModoEmp		:= ""
Local cModoUni		:= ""
Local cCodEmp			:= ""
Local cArquivo		:= ""
Local nCont			:= 0
Local lCt230Trb		:= ExistBlock("CT230TRB")
Local lRet				:= .T.
Local cAglutCT1		:= ""
Local cAglutCTT		:= ""
Local cContaIni		:= ""
Local cContaFim		:= ""
Local cCCustoIni		:= ""
Local cCCustoFim		:= ""
Local cItemIni		:= ""
Local cItemFim		:= ""
Local cClasseIni		:= ""
Local cClasseFim		:= ""

Private cEmpP := ""

// Recarrega variaveis
lConta 	:= .F.
lCusto		:= .F.
lItem		:= .F.
lClasse	:= .F.

If (!Empty(CTB->CTB_CTADES).And. !Empty(CTB->CTB_CT1INI) .And. !Empty(CTB->CTB_CT1FIM))	// Saldo a partir da Conta
	lConta := .T.
EndIf
If (!Empty(CTB->CTB_CCDES) .And. !Empty(CTB->CTB_CTTINI) .And. !Empty(CTB->CTB_CTTFIM))// Saldo a partir do C.Custo
	lCusto := .T.
Endif
If (!Empty(CTB->CTB_ITEMDE) .And. !Empty(CTB->CTB_CTDINI) .And. !Empty(CTB->CTB_CTDFIM))	// Saldo a partir do Item
	lItem := .T.
Endif
If (!Empty(CTB->CTB_CLVLDE) .And. !Empty(CTB->CTB_CTHINI) .And. !Empty(CTB->CTB_CTHFIM))		// Saldo a partir da classe
	lClasse := .T.
Endif

cCodemp := CTB->CTB_EMPORI
cEmpP := cCodemp

cContaIni		:= CTB->CTB_CT1INI
cContaFim		:= CTB->CTB_CT1FIM
cCCustoIni		:= CTB->CTB_CTTINI
cCCustoFim		:= CTB->CTB_CTTFIM
cItemIni		:= CTB->CTB_CTDINI
cItemFim		:= CTB->CTB_CTDFIM
cClasseIni		:= CTB->CTB_CTHINI
cClasseFim		:= CTB->CTB_CTHFIM
cTpSaldo		:= CTB->CTB_TPSLDO

// Saldos Plano de Contas
If lConta
	if lClasse
		Ct230Alias("CQ7",@cModoSX2,@cArquivo,@cModoEmp,@cModoUni, cEmpP)
	elseif lItem
		Ct230Alias("CQ5",@cModoSX2,@cArquivo,@cModoEmp,@cModoUni, cEmpP)
	elseif lCusto
		Ct230Alias("CQ3",@cModoSX2,@cArquivo,@cModoEmp,@cModoUni, cEmpP)
	else
		Ct230Alias("CQ1",@cModoSX2,@cArquivo,@cModoEmp,@cModoUni, cEmpP)
	EndIf
	
	cFilX := CtGetFil(CTB->CTB_EMPORI, CTB->CTB_FILORI, cModoSX2, cModoUni, cModoEmp)
	
	For nCont := 1 to nMoedas
		If mv_par05 == 1
			cMoeda := StrZero(nCont,2)
		Endif

		cAglutCT1 := "cAglutCT1"
				
		if lClasse		
			// Saldo Atual
			cQuery := " SELECT "
			cQuery += " CQ7_DATA DDATAATU, "
			cQuery += " SUM(CQ7_DEBITO) DEBITO,"
			cQuery += " SUM(CQ7_CREDIT) CREDITO "
			cQuery += " FROM "+ cArquivo +" CQ7 "
			cQuery += " WHERE CQ7.CQ7_FILIAL='"+cFilX+"' AND "
			cQuery += " CQ7.CQ7_CLVL>='"+cClasseIni+"' AND "
			cQuery += " CQ7.CQ7_CLVL<='"+cClasseFim+"' AND "
			If lCusto
				cQuery += " CQ7.CQ7_CCUSTO>='"+cCCustoIni+"' AND "
				cQuery += " CQ7.CQ7_CCUSTO<='"+cCCustoFim+"' AND "
			Endif
			If lConta
				cQuery += " CQ7.CQ7_CONTA>='"+cContaIni+"' AND "
				cQuery += " CQ7.CQ7_CONTA<='"+cContaFim+"' AND "
			Endif
			If lItem
				cQuery += " CQ7.CQ7_ITEM>='"+cItemIni+"' AND "
				cQuery += " CQ7.CQ7_ITEM<='"+cItemFim+"' AND "
			Endif
			cQuery += " CQ7.CQ7_MOEDA='"+cMoeda+"' AND "
			cQuery += " CQ7.CQ7_TPSALD='"+cTpSaldo+"' AND "
			cQuery += " CQ7.CQ7_DATA between '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+ "' AND "
			cQuery += " CQ7.D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY CQ7_DATA "

		elseif lItem			
			// Saldo Atual
			cQuery := " SELECT "
			cQuery += " CQ5_DATA DDATAATU, "
			cQuery += " SUM(CQ5_DEBITO) DEBITO,"
			cQuery += " SUM(CQ5_CREDIT) CREDITO "
			cQuery += " FROM "+ cArquivo +" CQ5 "
			cQuery += " WHERE CQ5.CQ5_FILIAL='"+cFilX+"' AND "
			cQuery += "CQ5.CQ5_ITEM>='"+cItemIni+"' AND "
			cQuery += "CQ5.CQ5_ITEM<='"+cItemFim+"' AND "
			If lCusto
				cQuery += " CQ5.CQ5_CCUSTO>='"+cCCustoIni+"' AND "
				cQuery += " CQ5.CQ5_CCUSTO<='"+cCCustoFim+"' AND "
			Endif
			If lConta
				cQuery += " CQ5.CQ5_CONTA>='"+cContaIni+"' AND "
				cQuery += " CQ5.CQ5_CONTA<='"+cContaFim+"' AND "
			Endif
			cQuery += " CQ5.CQ5_MOEDA='"+cMoeda+"' AND "
			cQuery += " CQ5.CQ5_TPSALD='"+cTpSaldo+"' AND "
			cQuery += " CQ5.CQ5_DATA between '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+ "' AND "
			cQuery += " CQ5.D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY CQ5_DATA "
		elseif lCusto		
			// Saldo Atual
			cQuery := " SELECT "
			cQuery += " CQ3_DATA DDATAATU, "
			cQuery += " SUM(CQ3_DEBITO) DEBITO,"
			cQuery += " SUM(CQ3_CREDIT) CREDITO "
			cQuery += " FROM "+ cArquivo +" CQ3 "
			cQuery += " WHERE CQ3.CQ3_FILIAL='"+cFilX+"' AND "
			cQuery += " CQ3.CQ3_CCUSTO>='"+cCCustoIni+"' AND "
			cQuery += " CQ3.CQ3_CCUSTO<='"+cCCustoFim+"' AND "

			If lConta
				cQuery += " CQ3.CQ3_CONTA>='"+cContaIni+"' AND "
				cQuery += " CQ3.CQ3_CONTA<='"+cContaFim+"' AND "
			Endif
			cQuery += " CQ3.CQ3_MOEDA='"+cMoeda+"' AND "
			cQuery += " CQ3.CQ3_TPSALD='"+cTpSaldo+"' AND "
			cQuery += " CQ3.CQ3_DATA between '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+ "' AND "
			cQuery += " CQ3.D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY CQ3_DATA "
		else	
			// Saldo Atual
			cQuery := " SELECT "
			cQuery += " CQ1_DATA DDATAATU, "
			cQuery += " SUM(CQ1_DEBITO) DEBITO,"
			cQuery += " SUM(CQ1_CREDIT) CREDITO "
			cQuery += " FROM "+ cArquivo +" CQ1 "
			cQuery += " WHERE CQ1.CQ1_FILIAL='"+cFilX+"' AND "
			cQuery += " CQ1.CQ1_CONTA>='"+cContaIni+"' AND "
			cQuery += " CQ1.CQ1_CONTA<='"+cContaFim+"' AND "

			cQuery += " CQ1.CQ1_MOEDA='"+cMoeda+"' AND "
			cQuery += " CQ1.CQ1_TPSALD='"+cTpSaldo+"' AND "
			cQuery += " CQ1.CQ1_DATA between '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+ "' AND "
			cQuery += " CQ1.D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY CQ1_DATA "
		EndIf
		
		cQuery    := ChangeQuery(cQuery)

		If Select(cAglutCT1) > 0
			dbSelectArea(cAglutCT1)
			dbCloseArea()
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAglutCT1,.T.,.F.)
		TcSetField(cAglutCT1,"DEBITO","N",aTam[1],aTam[2])
		TcSetField(cAglutCT1,"CREDITO","N",aTam[1],aTam[2])		
		dbSelectArea(cAglutCT1)
		
		While (cAglutCT1)->(!Eof())
			dDataAtu := cAglutCT1->DDATAATU
			AADD(aSaldoCta,(cAglutCT1)->DEBITO)
			AADD(aSaldoCta,(cAglutCT1)->CREDITO)
				
			cKey := (dDataAtu+CTB->CTB_CTADES+Space(Len(CTB->CTB_CCDES))+Space(Len(CTB->CTB_ITEMDE))+Space(Len(CTB->CTB_CLVLDE))+cMoeda+CTB->CTB_TPSLDE)
			
			If lCt230Trb
				lRet := ExecBlock("CT230TRB",.F.,.F.,{CTB->CTB_CTADES,Space(Len(CTB->CTB_CCDES)),Space(Len(CTB->CTB_ITEMDE)),Space(Len(CTB->CTB_CLVLDE))})
			Endif
			
			If lRet
				Ct230GrTrb("CT1",cKey,cMoeda,aSaldoCta,dDataAtu)
			Endif
			
			aSaldoCta := {}
			(cAglutCT1)->(dbSkip())
		End
		If Select(cAglutCT1) > 0
			dbSelectArea(cAglutCT1)
			dbCloseArea()
		EndIf
	Next
	
EndIf



// Saldos Centro de Custo
If lCusto

	Ct230Alias("CQ3",@cModoSX2,@cArquivo,@cModoEmp,@cModoUni, cEmpP)
	cFilX := CtGetFil(CTB->CTB_EMPORI, CTB->CTB_FILORI, cModoSX2, cModoUni, cModoEmp)
		
	For nCont := 1 to nMoedas
		If mv_par05 == 1
			cMoeda := StrZero(nCont,2)
		Endif
		
		cAglutCTT := "cAglutCTT"
	
		// Saldo Atual
		cQuery := " SELECT "
		cQuery += " CQ3_DATA DDATAATU, "
		cQuery += " SUM(CQ3_DEBITO) DEBITO,"
		cQuery += " SUM(CQ3_CREDIT) CREDITO "
		cQuery += " FROM "+ cArquivo +" CQ3 "
		cQuery += " WHERE CQ3.CQ3_FILIAL='"+cFilX+"' AND "
		cQuery += " CQ3.CQ3_CCUSTO>='"+cCCustoIni+"' AND "
		cQuery += " CQ3.CQ3_CCUSTO<='"+cCCustoFim+"' AND "

		If lConta
			cQuery += " CQ3.CQ3_CONTA>='"+cContaIni+"' AND "
			cQuery += " CQ3.CQ3_CONTA<='"+cContaFim+"' AND "
		Endif
		cQuery += " CQ3.CQ3_MOEDA='"+cMoeda+"' AND "
		cQuery += " CQ3.CQ3_TPSALD='"+cTpSaldo+"' AND "
		cQuery += " CQ3.CQ3_DATA between '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+ "' AND "
		cQuery += " CQ3.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY CQ3_DATA "	
		
		cQuery    := ChangeQuery(cQuery)
		
		If Select(cAglutCTT) > 0
			dbSelectArea(cAglutCTT)
			dbCloseArea()
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAglutCTT,.T.,.F.)
		
		TcSetField(cAglutCTT,"DEBITO","N",aTam[1],aTam[2])
		TcSetField(cAglutCTT,"CREDITO","N",aTam[1],aTam[2])
				
		dbSelectArea(cAglutCTT)
		While (cAglutCTT)->(!Eof())
			dDataAtu := cAglutCTT->DDATAATU
			AADD(aSaldoCC,(cAglutCTT)->DEBITO)
			AADD(aSaldoCC,(cAglutCTT)->CREDITO)
			
			cKey := (dDataAtu+CTB->CTB_CTADES+CTB->CTB_CCDES+Space(Len(CTB->CTB_ITEMDE))+Space(Len(CTB->CTB_CLVLDE))+cMoeda+CTB->CTB_TPSLDE)
			
			If lCt230Trb
				lRet := ExecBlock("CT230TRB",.F.,.F.,{CTB->CTB_CTADES,CTB->CTB_CCDES,Space(Len(CTB->CTB_ITEMDE)),Space(Len(CTB->CTB_CLVLDE))})
			Endif
			
			If lRet
				Ct230GrTrb("CTT",cKey,cMoeda,aSaldoCC,dDataAtu)
			Endif
			
			aSaldoCC := {}
			(cAglutCTT)->(dbSkip())
		End
		(cAglutCTT)->(dbCloseArea())
	Next
Endif


// Saldos Itens Contabeis
If lItem
	
	Ct230Alias("CQ5",@cModoSX2,@cArquivo,@cModoEmp,@cModoUni, cEmpP)
	cFilX := CtGetFil(CTB->CTB_EMPORI, CTB->CTB_FILORI, cModoSX2, cModoUni, cModoEmp)

	For nCont := 1 to nMoedas
		If mv_par05 == 1
			cMoeda := StrZero(nCont,2)
		Endif

		cAglutCTD := "cAglutCTD"

		// Saldo Atual
		cQuery := " SELECT "
		cQuery += " CQ5_DATA DDATAATU, "
		cQuery += " SUM(CQ5_DEBITO) DEBITO,"
		cQuery += " SUM(CQ5_CREDIT) CREDITO "
		cQuery += " FROM "+ cArquivo +" CQ5 "
		cQuery += " WHERE CQ5.CQ5_FILIAL='"+cFilX+"' AND "
		cQuery += "CQ5.CQ5_ITEM>='"+cItemIni+"' AND "
		cQuery += "CQ5.CQ5_ITEM<='"+cItemFim+"' AND "
		If lCusto
			cQuery += " CQ5.CQ5_CCUSTO>='"+cCCustoIni+"' AND "
			cQuery += " CQ5.CQ5_CCUSTO<='"+cCCustoFim+"' AND "
		Endif
		If lConta
			cQuery += " CQ5.CQ5_CONTA>='"+cContaIni+"' AND "
			cQuery += " CQ5.CQ5_CONTA<='"+cContaFim+"' AND "
		Endif
		cQuery += " CQ5.CQ5_MOEDA='"+cMoeda+"' AND "
		cQuery += " CQ5.CQ5_TPSALD='"+cTpSaldo+"' AND "
		cQuery += " CQ5.CQ5_DATA between '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+ "' AND "
		cQuery += " CQ5.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY CQ5_DATA "

		cQuery    := ChangeQuery(cQuery)
	
		If Select(cAglutCTD) > 0
			dbSelectArea(cAglutCTD)
			dbCloseArea()
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAglutCTD,.T.,.F.)
		
		TcSetField(cAglutCTD,"DEBITO","N",aTam[1],aTam[2])
		TcSetField(cAglutCTD,"CREDITO","N",aTam[1],aTam[2])
		
		dbSelectArea(cAglutCTD)
		
		While (cAglutCTD)->(!Eof())
			dDataAtu := cAglutCTD->DDATAATU
			AADD(aSaldoItem,(cAglutCTD)->DEBITO)
			AADD(aSaldoItem,(cAglutCTD)->CREDITO)
			
			cKey := (dDataAtu+CTB->CTB_CTADES+CTB->CTB_CCDES+CTB->CTB_ITEMDE+Space(Len(CTB->CTB_CLVLDE))+cMoeda+CTB->CTB_TPSLDE)
			
			If lCt230Trb
				lRet := ExecBlock("CT230TRB",.F.,.F.,{CTB->CTB_CTADES,CTB->CTB_CCDES,CTB->CTB_ITEMDE,Space(Len(CTB->CTB_CLVLDE))})
			Endif
			
			If lRet
				Ct230GrTrb("CTD",cKey,cMoeda,aSaldoItem,dDataAtu)
			Endif
			
			aSaldoItem := {}

			(cAglutCTD)->(dbSkip())
		End
		
		If Select(cAglutCTD) > 0
			dbSelectArea(cAglutCTD)
			dbCloseArea()
		EndIf
		
	Next
EndIf

// Saldos Classe de Valor
If lClasse
	
	Ct230Alias("CQ7",@cModoSX2,@cArquivo,@cModoEmp,@cModoUni, cEmpP)
	cFilX := CtGetFil(CTB->CTB_EMPORI, CTB->CTB_FILORI, cModoSX2, cModoUni, cModoEmp)
	
	For nCont := 1 to nMoedas
		If mv_par05 == 1
			cMoeda := StrZero(nCont,2)
		Endif
		cAglutCTH := "cAglutCTH"
		
		// Saldo Atual
		cQuery := " SELECT "
		cQuery += " CQ7_DATA DDATAATU, "
		cQuery += " SUM(CQ7_DEBITO) DEBITO,"
		cQuery += " SUM(CQ7_CREDIT) CREDITO "
		cQuery += " FROM "+ cArquivo +" CQ7 "
		cQuery += " WHERE CQ7.CQ7_FILIAL='"+cFilX+"' AND "
		cQuery += " CQ7.CQ7_CLVL>='"+cClasseIni+"' AND "
		cQuery += " CQ7.CQ7_CLVL<='"+cClasseFim+"' AND "
		If lCusto
			cQuery += " CQ7.CQ7_CCUSTO>='"+cCCustoIni+"' AND "
			cQuery += " CQ7.CQ7_CCUSTO<='"+cCCustoFim+"' AND "
		Endif
		If lConta
			cQuery += " CQ7.CQ7_CONTA>='"+cContaIni+"' AND "
			cQuery += " CQ7.CQ7_CONTA<='"+cContaFim+"' AND "
		Endif
		If lItem
			cQuery += " CQ7.CQ7_ITEM>='"+cItemIni+"' AND "
			cQuery += " CQ7.CQ7_ITEM<='"+cItemFim+"' AND "
		Endif
		cQuery += " CQ7.CQ7_MOEDA='"+cMoeda+"' AND "
		cQuery += " CQ7.CQ7_TPSALD='"+cTpSaldo+"' AND "
		cQuery += " CQ7.CQ7_DATA between '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+ "' AND "
		cQuery += " CQ7.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY CQ7_DATA "
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAglutCTH,.T.,.F.)
		
		aTam := TamSx3('CT2_VALOR')
		TcSetField(cAglutCTH,"DEBITO","N",aTam[1],aTam[2])
		TcSetField(cAglutCTH,"CREDITO","N",aTam[1],aTam[2])
		
		While (cAglutCTH)->(!Eof())
			dDataAtu := cAglutCTH->DDATAATU
			AADD(aSaldoClvl,(cAglutCTH)->DEBITO)
			AADD(aSaldoClvl,(cAglutCTH)->CREDITO)
			
			cKey := (dDataAtu+CTB->CTB_CTADES+CTB->CTB_CCDES+CTB->CTB_ITEMDE+CTB->CTB_CLVLDE+cMoeda+CTB->CTB_TPSLDE)
			
			If lCt230Trb
				lRet := ExecBlock("CT230TRB",.F.,.F.,{CTB->CTB_CTADES,CTB->CTB_CCDES,CTB->CTB_ITEMDE,CTB->CTB_CLVLDE})
			Endif
			
			If lRet
				Ct230GrTrb("CTH",cKey,cMoeda,aSaldoClVl,dDataAtu)
			Endif
			
			aSaldoClVl:= {}
			(cAglutCTH)->(dbSkip())
		End
		dbSelectArea(cAglutCTH)
		dbCloseArea()
	Next
	
EndIf

// Processamento das outras entidades
If _nQtdEntid > 4
	If GetMv('MV_CTBCUBE',.F.,"0")=="1"
		Ct230Alias("CVX",@cModoSX2,@cArquivo,@cModoEmp,@cModoUni, cEmpP)
		cFilX := CtGetFil(CTB->CTB_EMPORI, CTB->CTB_FILORI, cModoSX2, cModoUni, cModoEmp)
		
		For nCont := 1 to nMoedas
			
			If mv_par05 == 1
				cMoeda := StrZero(nCont,2)
			Endif
			
			Ct230GrEnt(dDataIni,dDataFim,cMoeda,CTB->CTB_TPSLDO,cCodigo,cFilx,cArquivo)
			
		Next nCont
		
	Else
		ApMsgInfo('Empresa destino não cadastrado conf. de entidades contabeis.')
	EndIF
EndIf


RestArea(aSaveArea)

                          

Return

//-------------------------------------------------------------------
/*{Protheus.doc} Ct230GrTrb
Grava no Arq. de Trabalho os mov. debito/credito. 

@author Alvaro Camillo Neto

@param cAlias Alias do Arquivo                                   
@param cChave Chave                                              
@param cMoeda Moeda                                              
@param aSaldo Array contendo os saldos                           
@param dDataAtu Data                                               
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ct230GrTrb(cAlias,cChave,cMoeda,aSaldo,dDataAtu)

Local aSaveArea := GetArea()         
	
dbSelectArea("TRB")
dbSetOrder(1)
If !DbSeek(cChave) 	 
	Reclock("TRB",.T.)  	
	If cAlias == "CTT"
		TRB->CUSTO	:= CTB->CTB_CCDES
	ElseIf cAlias == "CTD"
		TRB->CUSTO	:= CTB->CTB_CCDES	 		
		TRB->ITEM	:= CTB->CTB_ITEMDE
	ElseIf cAlias == "CTH"
		TRB->CUSTO	:= CTB->CTB_CCDES
		TRB->ITEM	:= CTB->CTB_ITEMDE
		TRB->CLVL	:= CTB->CTB_CLVLDE
    Endif					
	TRB->CONTA  	:= CTB->CTB_CTADEST 
	TRB->DTSALDO	:= STOD(dDataAtu)

	TRB->MOEDA  	:= cMoeda
	TRB->TPSALDO	:= CTB->CTB_TPSLDE
	TRB->DEBITO 	:= aSaldo[1]
	TRB->CREDITO	:= aSaldo[2]
	MsUnlock()
Else
	Reclock("TRB",.F.)   
	If CTB->CTB_IDENT == "1"
		TRB->DEBITO 	+= aSaldo[1]
		TRB->CREDITO	+= aSaldo[2]         
	ElseIf CTB->CTB_IDENT == "2"
		TRB->DEBITO 	-= aSaldo[1]
		TRB->CREDITO 	-= aSaldo[2]
	Endif                                   
	MsUnlock()
Endif		   

RestArea(aSaveArea)

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct230GrEntºAutor  ³TOTVS               º Data ³  06/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava saldos por entidades                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct230GrEnt(dDataIni,dDataFim,cMoeda,nMoedas,cCodigo,cFilx,cArquivo)
Local aAliasAux := GetArea() 
Local cQuery := "SELECT "
Local nEntid
Local nX		:= 0 
Local cCpo		:= "CVX_NIV"
Local cCampos	:= ""
Local cField	:= "" 
Local aCpos		:= ""
Local nQtdEntid	 
Local nCont 	:= 0 
Local nPos		:= 0 
Local cChave	:= ""
Local cChaveD	:= ""  
Local cChaveC	:= "" 
Local nVlrDeb	:= 0
Local nVlrCre	:= 0 
Local cTipoLanc	:= ""

Local aEntidAux := {} 

Private cCodMoeda:= cMoeda
Static cAliasQry:= GetNextAlias()

If lDefTopCTB  

	aCpos := ARRAY( _nQtdEntid,6 )

	cChaveD :=  'cCodMoeda+DTOS((cAliasQry)->CVX_DATA)+CTB->CTB_TPSLDO+"1"'  
	cChaveC :=  'cCodMoeda+DTOS((cAliasQry)->CVX_DATA)+CTB->CTB_TPSLDO+"2"' 

	For nEntid:=1 To Len(aCpos)
		
		aCpos[nEntid][1] :=cCpo + StrZero(nEntid,2)  
		
		cCampos += Alltrim(aCpos[nEntid][1]) + Iif(nEntid<Len(aCpos),",","")  
		
		If nEntid == 1		
			aCpos[nEntid][2] := "CTB->CTB_CT1INI"
			aCpos[nEntid][3] := "CTB->CTB_CT1FIM"  
			aCpos[nEntid][4] := "CTB->CTB_CTADES" 
			aCpos[nEntid][5] := "CT2_DEBITO" 
			aCpos[nEntid][6] := "CT2_CREDIT"			
			cChave += "+CTB->CTB_CTADES"
		ElseIf nEntid == 2					
			aCpos[nEntid][2] := "CTB->CTB_CTTINI"
			aCpos[nEntid][3] := "CTB->CTB_CTTFIM"
			aCpos[nEntid][4] := "CTB->CTB_CCDES" 
			aCpos[nEntid][5] := "CT2_CCD" 
			aCpos[nEntid][6] := "CT2_CCC"										
			cChave += '+CTB->CTB_CCDES'
		ElseIf nEntid == 3				
			aCpos[nEntid][2] := "CTB->CTB_CTDINI"
			aCpos[nEntid][3] := "CTB->CTB_CTDFIM"              
			aCpos[nEntid][4] := "CTB->CTB_ITEMDE"			
			aCpos[nEntid][5] := "CT2_ITEMD" 
			aCpos[nEntid][6] := "CT2_ITEMC"										
			cChave += '+CTB->CTB_ITEMDE'
		ElseIf nEntid == 4				
			aCpos[nEntid][2] := "CTB->CTB_CTHINI"
			aCpos[nEntid][3] := "CTB->CTB_CTHFIM"		        
			aCpos[nEntid][4] := "CTB->CTB_CLVLDE"			
			aCpos[nEntid][5] := "CT2_CLVLDB" 
			aCpos[nEntid][6] := "CT2_CLVLCR"										
			cChave += '+CTB->CTB_CLVLDE'
		Else	
			aCpos[nEntid][2] := "CTB->CTB_E"+StrZero(nEntid,2)+"INI" 
			aCpos[nEntid][3] := "CTB->CTB_E"+StrZero(nEntid,2)+"FIM"
			aCpos[nEntid][4] := "CTB->CTB_E"+StrZero(nEntid,2)+"DES"							
			aCpos[nEntid][5] := "CT2_EC"+StrZero(nEntid,2)+"DB" 
			aCpos[nEntid][6] := "CT2_EC"+StrZero(nEntid,2)+"CR"						
			cChave += '+CTB->CTB_E'+StrZero(nEntid,2)+'DES'			
		EndIf			

	Next nEntid  
	
	cChaveD += cChave
	cChaveC	+= cChave
	
	cQuery += "CVX_CONFIG,CVX_DATA,CVX_MOEDA,CVX_TPSALD,CVX_SLDCRD,CVX_SLDDEB,"+cCampos
	cQuery += " FROM "+cArquivo +" WHERE CVX_FILIAL = '"+cFilx+"' " 
	cQuery += " AND CVX_CONFIG = '"+StrZero(_nQtdEntid,2)+"' "    
	cQuery += " AND CVX_DATA >= '"+Dtos(dDataIni)+"' "    
	cQuery += " AND CVX_DATA <= '"+Dtos(dDataFim)+"' " 
	cQuery += " AND CVX_MOEDA = '"+cMoeda+"' "  
	cQuery += " AND CVX_TPSALD = '"+CTB->CTB_TPSLDO+"' " 
	                    
	For nX:=1 To Len(aCpos)
		If !Empty(&(aCpos[nX][2])) .And. !Empty(&(aCpos[nX][3]))	 
			cQuery += " AND " + aCpos[nX][1] + " BETWEEN '" + Alltrim(&(aCpos[nX][2])) + "' AND '" + Alltrim(&(aCpos[nX][3]))+ "' "
		EndIf			
	Next nX  
	
	cQuery += " AND D_E_L_E_T_ = ' ' "  
	
	cQuery:= ChangeQuery(cQuery)      
//	Conout(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. )
	TcSetField(cAliasQry,"CVX_DATA","D",8,0) 
	TcSetField(cAliasQry,"CVX_SLDDEB","N",TamSx3("CVX_SLDDEB")[1],TamSx3("CVX_SLDDEB")[2])
	TcSetField(cAliasQry,"CVX_SLDCRD","N",TamSx3("CVX_SLDCRD")[1],TamSx3("CVX_SLDCRD")[2])	
	
	dbSelectArea(cAliasQry)
	dbGoTop()
	
	While (cAliasQry)->(!Eof()) 
	
		nVlrDeb	:= (cAliasQry)->CVX_SLDDEB
		nVlrCre	:= (cAliasQry)->CVX_SLDCRD	
		
//		1=Debito;2=Credito;3=Partida Dobrada
		dbSelectArea('TRB2')  
		
		If nVlrDeb > 0
			dbSetOrder(1)
			If !dbSeek( &(cChaveD) )
				RecLock('TRB2',.T.)
					TRB2->CT2_MOEDLC	:= (cAliasQry)->CVX_MOEDA
					TRB2->CT2_DATA		:= (cAliasQry)->CVX_DATA
					TRB2->CT2_TPSALD	:= (cAliasQry)->CVX_TPSALD 
					TRB2->CT2_DC		:= '1'		
					TRB2->CT2_VALOR		:= nVlrDeb
					For nX:=1 To Len(aCpos)
						TRB2->&(aCpos[nX][5]) := &(aCpos[nX][4])				 
					Next nX							
				MsUnlock() 
			Else
				RecLock('TRB2',.F.)		
					TRB2->CT2_VALOR := TRB2->CT2_VALOR + nVlrDeb 
				MsUnlock()			
			EndIf  
		EndIf
	
		If nVlrCre > 0
			dbSetOrder(2)
			If !dbSeek( &(cChaveC) )
				RecLock('TRB2',.T.)
					TRB2->CT2_MOEDLC	:= (cAliasQry)->CVX_MOEDA
					TRB2->CT2_DATA		:= (cAliasQry)->CVX_DATA
					TRB2->CT2_TPSALD	:= (cAliasQry)->CVX_TPSALD 
					TRB2->CT2_DC		:= '2'		
					TRB2->CT2_VALOR		:= nVlrCre
					For nX:=1 To Len(aCpos)
						TRB2->&(aCpos[nX][6]) := &(aCpos[nX][4])				 
					Next nX							
				MsUnlock() 
			Else
				RecLock('TRB2',.F.)		
					TRB2->CT2_VALOR := TRB2->CT2_VALOR + nVlrCre 
				MsUnlock()			
			EndIf  
		EndIf
		
		(cAliasQry)->(DbSkip())	
	EndDo 
	
	dbSelectArea(cAliasQry)
	dbCloseArea()
	
EndIf

RestArea(aAliasAux)
Return()  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct230SldEnt  Autor ³ TOTVS                   ³ Data 12.05.10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Gera Registro de arquivo de Saldo                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct230SldEnt()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³                                                            ³±±
±±³           ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct230SldEnt()
Local aAreaAtu		:= GetArea()  
Local oConjCubos	:= Ctb_Load_Cubes()

dbSelectArea("TRB2")
dbSetOrder(1) 
dbGotop()          
While TRB2->(!Eof())
	Ctb_Run_Cubes(oConjCubos,"TRB2"/*cAliasMov*/,/*cOperacao*/)   //grava saldo nos cubos                          
	TRB2->(DbSkip())
EndDo	

RestArea(aAreaAtu)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtGetFil  ³ Autor  ³ Marcelo Akama           ³ Data 22/08/11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Gera codigo de filial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ CtGetFil()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³                                                            ³±±
±±³           ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CtGetFil(cEmp, cFil, cModo, cModoUn, cModoEmp)
Local aSM0		:= AdmAbreSM0()
Local nPos
Local cRet		:= cFil
Local cEmpresa	:= ''
Local cUnidade	:= ''
Local cFilAux	:= ''
Local aMask		:= {}
Local nX

nPos := aScan(aSM0, {|x| x[1]==PADR(cEmp,Len(x[1])) .And. x[2]==PADR(cFil,Len(x[2])) .And. Len(alltrim(cEmp))<=Len(x[1]) .And. Len(alltrim(cFil))<=Len(x[2]) })

If nPos>0
	cEmpresa := IIf(cModoEmp=='E',aSM0[nPos][3],Space(len(aSM0[nPos][3])))
	cUnidade := IIf(cModoUn =='E',aSM0[nPos][4],Space(len(aSM0[nPos][4])))
	cFilAux  := IIf(cModo   =='E',aSM0[nPos][5],Space(len(aSM0[nPos][5])))
	If Empty(aSM0[nPos][9])
		cRet := cFilAux
	Else
		cRet := ''
		aMask := {}
		AADD(aMask,{'E', At(aSM0[nPos][13],aSM0[nPos][9])})
		AADD(aMask,{'U', At(aSM0[nPos][14],aSM0[nPos][9])})
		AADD(aMask,{'F', At(aSM0[nPos][15],aSM0[nPos][9])})
		aMask := ASORT(aMask,,, { |x, y| x[2] < y[2] })
		For nX := 1 to Len(aMask)
			Do Case
				Case aMask[nX][1]=='E'
					cRet += cEmpresa
				Case aMask[nX][1]=='U'
					cRet += cUnidade
				Case aMask[nX][1]=='F'
					cRet += cFilAux
			EndCase
		Next
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} Ctb190CQ8
Gra                                 

@author Totvs

@version P12
@since   24.07.2007

@obs	 
*/
//-------------------------------------------------------------------  
Static Function Ctb230CQ8(cTpSald,cFilx,dDataIni,dDataFim)
Local aArea  := GetArea()
Local cQuery := ""
Local cTab   := GetNextAlias()
Local aTamCT2:= TamSX3("CT2_VALOR")


cIdent := "CTT"
cQuery := ""
cQuery += " Select CQ3_FILIAL FILIAL , CQ3_CCUSTO CODIGO , CQ3_MOEDA MOEDA, CQ3_DATA DATASL, CQ3_DTLP DATALP,CQ3_LP LP , SUM(CQ3_DEBITO) DEBITO ,SUM(CQ3_CREDIT) CREDITO " +CRLF
cQuery += "  From "+ RetSqlName("CQ3") +CRLF
cQuery += " Where CQ3_FILIAL = '"+xFilial("CQ3",cFilx)+"' " +CRLF
cQuery += "   and CQ3_TPSALD = '"+cTpSald+"' " +CRLF
cQuery += "   and (CQ3_DATA between '"+DTOS(dDataIni)+"' and '"+DTOS(dDataFim)+"') " +CRLF
cQuery += "   and D_E_L_E_T_= ' ' " +CRLF
cQuery += " Group By CQ3_FILIAL, CQ3_CCUSTO , CQ3_MOEDA, CQ3_DATA, CQ3_DTLP,CQ3_LP " +CRLF
cQuery  += " order by 1,2,3,4,5,6 " +CRLF
cQuery := Changequery(cQuery)

If ( Select ( cTab ) > 0 )
	dbSelectArea ( cTab )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.F.)

TCSetField(cTab,"DATASL", "D",8,0)
TCSetField(cTab,"DATALP", "D",8,0)
TCSetField(cTab,"DEBITO", "N",aTamCT2[1],aTamCT2[2])
TCSetField(cTab,"CREDITO", "N",aTamCT2[1],aTamCT2[2])

While (cTab)->(!EOF())
	cChvEntMes  	:= (cTab)->(FILIAL+DTOS(LastDay(DATASL))+cIdent+CODIGO+MOEDA+cTpSald+LP)
	cChvEntDia  	:= (cTab)->(FILIAL+DTOS(DATASL)+cIdent+CODIGO+MOEDA+cTpSald+LP)
	xCt230CQ8(cChvEntMes,cChvEntDia,cIdent,(cTab)->CODIGO,cTpSald,(cTab)->LP,(cTab)->DEBITO,(cTab)->CREDITO,(cTab)->DATASL,(cTab)->FILIAL,(cTab)->MOEDA,(cTab)->LP,(cTab)->DATALP)
	
	(cTab)->(dbSkip())
EndDo




cIdent := "CTD"
cQuery := ""
cQuery += " Select CQ5_FILIAL FILIAL , CQ5_ITEM CODIGO , CQ5_MOEDA MOEDA, CQ5_DATA DATASL, CQ5_DTLP DATALP,CQ5_LP LP , SUM(CQ5_DEBITO) DEBITO ,SUM(CQ5_CREDIT) CREDITO " +CRLF
cQuery += "  From "+ RetSqlName("CQ5") +CRLF
cQuery += " Where CQ5_FILIAL = '"+xFilial("CQ5",cFilx)+"' " +CRLF
cQuery += "   and CQ5_TPSALD = '"+cTpSald+"' " +CRLF
cQuery += "   and (CQ5_DATA between '"+DTOS(dDataIni)+"' and '"+DTOS(dDataFim)+"') " +CRLF
cQuery += "   and D_E_L_E_T_= ' ' " +CRLF
cQuery += " Group By CQ5_FILIAL, CQ5_ITEM , CQ5_MOEDA, CQ5_DATA, CQ5_DTLP,CQ5_LP " +CRLF
cQuery  += " order by 1,2,3,4,5,6 " +CRLF
cQuery := Changequery(cQuery)

If ( Select ( cTab ) > 0 )
	dbSelectArea ( cTab )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.F.)



TCSetField(cTab,"DATASL", "D",8,0)
TCSetField(cTab,"DATALP", "D",8,0)
TCSetField(cTab,"DEBITO", "N",aTamCT2[1],aTamCT2[2])
TCSetField(cTab,"CREDITO", "N",aTamCT2[1],aTamCT2[2])

While (cTab)->(!EOF())
	cChvEntMes  	:= (cTab)->(FILIAL+DTOS(LastDay(DATASL))+cIdent+CODIGO+MOEDA+cTpSald+LP)
	cChvEntDia  	:= (cTab)->(FILIAL+DTOS(DATASL)+cIdent+CODIGO+MOEDA+cTpSald+LP)
	xCt230CQ8(cChvEntMes,cChvEntDia,cIdent,(cTab)->CODIGO,cTpSald,(cTab)->LP,(cTab)->DEBITO,(cTab)->CREDITO,(cTab)->DATASL,(cTab)->FILIAL,(cTab)->MOEDA,(cTab)->LP,(cTab)->DATALP)
	
	(cTab)->(dbSkip())
EndDo



cIdent := "CTH"
cQuery := ""
cQuery += " Select CQ7_FILIAL FILIAL , CQ7_CLVL CODIGO , CQ7_MOEDA MOEDA, CQ7_DATA DATASL, CQ7_DTLP DATALP,CQ7_LP LP , SUM(CQ7_DEBITO) DEBITO ,SUM(CQ7_CREDIT) CREDITO " +CRLF
cQuery += "  From "+ RetSqlName("CQ7") +CRLF
cQuery += " Where CQ7_FILIAL = '"+xFilial("CQ7",cFilx)+"' " +CRLF
cQuery += "   and CQ7_TPSALD = '"+cTpSald+"' " +CRLF
cQuery += "   and (CQ7_DATA between '"+DTOS(dDataIni)+"' and '"+DTOS(dDataFim)+"') " +CRLF
cQuery += "   and D_E_L_E_T_= ' ' " +CRLF
cQuery += " Group By CQ7_FILIAL, CQ7_CLVL , CQ7_MOEDA, CQ7_DATA, CQ7_DTLP,CQ7_LP " +CRLF
cQuery  += " order by 1,2,3,4,5,6 " +CRLF
cQuery := Changequery(cQuery)

If ( Select ( cTab ) > 0 )
	dbSelectArea ( cTab )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.F.)



TCSetField(cTab,"DATASL", "D",8,0)
TCSetField(cTab,"DATALP", "D",8,0)
TCSetField(cTab,"DEBITO", "N",aTamCT2[1],aTamCT2[2])
TCSetField(cTab,"CREDITO", "N",aTamCT2[1],aTamCT2[2])

While (cTab)->(!EOF())
	cChvEntMes  	:= (cTab)->(FILIAL+DTOS(LastDay(DATASL))+cIdent+CODIGO+MOEDA+cTpSald+LP)
	cChvEntDia  	:= (cTab)->(FILIAL+DTOS(DATASL)+cIdent+CODIGO+MOEDA+cTpSald+LP)
	xCt230CQ8(cChvEntMes,cChvEntDia,cIdent,(cTab)->CODIGO,cTpSald,(cTab)->LP,(cTab)->DEBITO,(cTab)->CREDITO,(cTab)->DATASL,(cTab)->FILIAL,(cTab)->MOEDA,(cTab)->LP,(cTab)->DATALP)
	
	(cTab)->(dbSkip())
EndDo

If ( Select ( cTab ) > 0 )
	dbSelectArea ( cTab )
	dbCloseArea ()
Endif	

RestArea(aArea)
Return



//-------------------------------------------------------------------
/*{Protheus.doc} xCt230CQ8
Grava os saldos nas tabelas

@author Alvaro Camillo Neto
                         
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function xCt230CQ8(cChaveMes,cChaveDia,cIdent,cCodigo,cTpSald,cLp,nDebito,nCredito,dDataSl,cFilSl,cMoeda,cLp,dDataLP)

Local aArq			:= Array(2)
Local dDiaMes		:= STOD("")
Local dDia			:= STOD("")
Local nX			:= 0
Local aSaveArea	:= GetArea() 
Local cArquivo	:= "" 
Local cChave		:= "" // Chave Utilizada para encontrar o saldo mensal

Local dData		:= STOD("")   
Local lNovo		:= .F.

Default cIdent  := ""
Default cCodigo := ""

dDiaMes	:= LastDay(dDataSl)
dDia		:= dDataSl

aArq[1] 		:= "CQ8"
aArq[2] 		:= "CQ9"

		
For nX := 1 to 2
	cArquivo := aArq[nX]
	dbSelectArea(cArquivo)
	(cArquivo)->(dbSetOrder(1))
	
	If nX == 1 // Saldo Mensal
		dData := dDiaMes
		cChave:= cChaveMes
	Else // Saldo Diário
		dData := dDia
		cChave:= cChaveDia
	EndIf
	
	If (cArquivo)->(MsSeek(cChave))
		lNovo := .F.
	Else
		lNovo := .T.
	EndIf
	
	RecLock(cArquivo,lNovo)
	
	&(cArquivo+"->"+cArquivo+"_FILIAL")		:= cFilSl
	&(cArquivo+"->"+cArquivo+"_MOEDA")			:= cMoeda
	&(cArquivo+"->"+cArquivo+"_TPSALD")		:= cTpSald
	
	&(cArquivo+"->"+cArquivo+"_DATA")			:= dData
	&(cArquivo+"->"+cArquivo+"_STATUS")		:= '1'
	&(cArquivo+"->"+cArquivo+"_LP")				:= cLp
	
	&(cArquivo+"->"+cArquivo+"_IDENT")			:= cIdent
	&(cArquivo+"->"+cArquivo+"_CODIGO")		:= cCodigo

	&(cArquivo+"->"+cArquivo+"_DTLP")			:= dDataLP

	
	If lNovo
		&(cArquivo+"->"+cArquivo+"_DEBITO")	:= nDebito
		&(cArquivo+"->"+cArquivo+"_CREDIT")	:= nCredito
	Else
		&(cArquivo+"->"+cArquivo+"_DEBITO")	+= nDebito
		&(cArquivo+"->"+cArquivo+"_CREDIT")	+= nCredito
	EndIf
	
	MsUnlock()
	
Next nX


RestArea(aSaveArea)

Return

