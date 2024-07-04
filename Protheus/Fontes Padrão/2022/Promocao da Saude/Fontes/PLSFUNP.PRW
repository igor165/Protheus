#include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSELEG   บAutor  ณ Rogerio Tabosa     บ Data ณ  03/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SAUDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSELEG(aJob,cVidas, cCodProg, aPergs, cRetCpos, lAjustQry, lIncBOM, cCodCrm,aRegra, lJob, oProcess)
Local aArea	    	:= getArea()
Local cSqlEle		:= "" //  Query com a jun็ใo das selects de todos os programs com UNIO
Local cSqlProg   	:= "" // Query de cada programa BOA_QRYELE
Local cCpoAtu		:= ""
Local cCpoUp		:= "" //Query que retornar o maior numero de campos sera utilizada no UNION
Local aProgramas	:= {} // Retorno dos programas que o paciente estiver eleg/inscrito caso seja passado o cVidas
Local aCposOb		:= {"BTS_MATVID", "BTS_NOMUSR", "BOA_CODPRO", "BOA_DESPRO", "BOM_STATUS", "BOB_GRAU", "BOB_GRAU", "BOC_ITECND"} // Campos obrigatorio do retorno
Local nI			:= 0 //Contador
Local nR			:= 0
Local nL			:= 0
Local cSeqBOM		:= "" // Numero sequencial de inclusใo do registro na BOM

//Variaves de Backup BOC_ITECND, BOC_ITEM, BOC_CONDIC, BTS.BTS_MATVID, BTS.BTS_NOMUSR,BOA_CODPRO,BOA_DESPRO, BOM.BOM_STATUS,BOB_GRAU, QTDCND "
Local cQryCODPRO	:= ""
Local cQryMATVID	:= ""
Local cQryIteCND	:= ""
Local cQryItem	    := ""
Local cQryDsCond	:= ""
Local nQryQtdCnd	:= 0     
Local cBkpOrder		:= ""
Local aQuerys		:= {} // Variavel onde sera guardada cada query de cada programa *criado para desmembrar por UNION querys muito grandes que o protheus/top nใo estava suportando
Local lCriouTab 	:= .F. // Flag de cria็ใo da tabela temporaria
Local aStruEle  	:= {} // Estrutura de campos da query
Local aProExe   	:= {} // Programas que serใo executados
Local cQryAtu		:= "" // Query atual do vetor aQuerys
Local nCoutBOC		:= 1
Local cSqlExec		:= ""

Local cJobName		:=	getWebJob()		//Nome do Job (Working Thread) em execucao
Local cCodEmp 	    :=""
Local cCodFil 		:=""

// Variaveis de APOIO para utiliza็ใo nas express๕es
Private cAno		:=""		 
Private cMes		:=""
Private cMesAnt		:=""
Private cAnoAnt		:=""
Private dDtIniDAn	
Private dDtFimDAn	
Private cDatIniAn	:=""
Private cDatFimAn	:=""
Private dDataIni	
Private dDataFim	
Private dDataIniA	
Private dDataFimA 
Private __cProWhere :=""  // Variavel utilizada na query

Default cVidas		:= ""		// Codigo da Vida que deseja verificar se ้ elegivel e/ou retornar os programas
Default cCodProg	:= "" // Codigo do programa que deseja verificar o(s) elegivel(is)
Default aPergs		:= {} // Perguntas do questionario que serใo passadas para verificar regra de elegibilidade { { CODPER , RESPOSTA } }
Default cRetCpos	:= "" // Campos que deverใo ser retornados na SELECT EX: "BTS_MATVID, BOA_DESPRO"
Default lAjustQry	:= .F. // Informa se a fun็ใo ira realizar processamento de ajuste na string das query para fazer o UNION
Default lIncBOM		:= .T. // Define se o elegivel encontrado sera incluso como elegivel na tabela BOM
Default cCodCrm		:= ""
Default aJob		:={}
Default aRegra		:={}
Default lJob		:= .F.
Default oProcess	:= Nil

If len(aJob)>0
	cCodEmp := aJob[1]
	cCodFil := aJob[2]
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil
	lJob := .T. // VARIAVEL PARA INDENTIFICAR SE ษ JOB

Endif

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Job Iniciado "+Time()+" Empresa : [" + cCodEmp + "]" + " Filial : [" + cCodFil + "]" , 0, 0, {})

 cAno		:= Substr(DTOC(dDataBase),7,4)
 cMes		:= StrZero(Month(dDataBase),2)
 cMesAnt	:= IIf(cMes == "01", "12", StrZero(Val(cMes)-1,2))
 cAnoAnt	:= Iif(cMesAnt == "12",Str(Val(cAno)-1),cAno)                           
 dDtIniDAn	:= CTOD("01/"+cMesAnt+"/"+cAnoAnt)
 dDtFimDAn	:= CTOD(StrZero(F_ULTDIA(dDtIniDAn),2)+"/"+cMesAnt+"/"+cAnoAnt)
 cDatIniAn	:= DTOS(dDtIniDAn)
 cDatFimAn	:= DTOS(dDtFimDAn)
 dDataIni	:= CTOD("01/"+cMes+"/"+cAno)
 dDataFim	:= CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
 dDataIniA	:= CTOD("01/01/"+cAno)                       
 dDataFimA := CTOD("31/12/"+cAno) 
 
If !lJob
	If !Empty(cVidas) //COLOCA A VIDA NA CONDIวรO
		__cProWhere += " AND BTS.BTS_MATVID ='" + cVidas + "'" 	
	EndIf 
Endif

If !Empty(cCodProg) //Somente programa selecionado
	If Len(aRegra) == 0 // Primeira vez veio sem regra busca do cadastro
		aRegra := PBusRegra(cCodProg)
	EndIf
	If Len(aRegra) == 0 // nao possui regra cadastrada nao roda
		If !lJob			
			HELP('PLSELEG',, 'PLSELEG',, "Programa: [" + cCodProg + "] nao possui regra de elegibilidade cadastrada!", 1, 0)	 //"Nใo foram encontrados novos elegiveis!"
		Else
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Programa: [" + cCodProg + "] nao possui regra de elegibilidade cadastrada" , 0, 0, {})
		EndIf
		Return({0})
	Else
		AADD(aProExe, {cCodProg,aRegra})
	EndIf
Else // todos os programas ativos da base   -- JOB
	DbSelectArea("BOA")
	BOA->(DbGoTop())
	BOA->(DbSetOrder(1))
	While !BOA->(Eof()) 
		If BOA->BOA_ATIVO == '1'
			aRegra := PBusRegra(BOA->BOA_CODPRO)
			If Len(aRegra) > 0
				AADD(aProExe, {BOA->BOA_CODPRO, aRegra}) 
			Else
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Programa: [" + BOA->BOA_CODPRO + "] nao possui regra de elegibilidade cadastrada" , 0, 0, {})
			EndIf          
		EndIf
		BOA->(DbSkip())
	EndDo	
EndIf

If !lJob .and. Valtype(oProcess) <> "U"
	oProcess:setRegua1(Len(aProExe))
EndIf 

For nL := 1 To Len(aProExe) // Executa programa por programa
	DbSelectArea("BOA")
	BOA->(DbGoTop())
	BOA->(DbSetOrder(1))
	BOA->(MsSeek(xFilial("BOA") + aProExe[nL,1]))
	If !lJob .and. Valtype(oProcess) <> "U"
		oProcess:IncRegua1("Buscando elegiveis do programa["+ Alltrim(BOA->BOA_DESPRO) +"]")
		oProcess:setRegua2(Len(aProExe[nL,2]))
	EndIf
	For nR := 1 to Len(aProExe[nL,2])
		PPrExeRegr(aProExe[nL,1], aProExe[nL,2,nR,1], @aProgramas, oProcess) // Programa + Regra		
		If !lJob .and. Valtype(oProcess) <> "U"
		oProcess:IncRegua2("Buscando elegiveis do programa["+ Alltrim(BOA->BOA_DESPRO) +"]")				
		Endif
	Next nR	
Next nL	
	

RestArea(aArea) 

If len(aJob)>0
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', " Job Processado com Sucesso" + TIME() , 0, 0, {})		
	RESET ENVIRONMENT	
Endif
	
Return(aProgramas)

//---------------------------------------------------------------------------
//GetCposRet - Retorno os campos do SELECT de retorno						   |
//---------------------------------------------------------------------------
Static Function PProExMacro(cSqlProg)
Local cQryMacro 	:= ""
Local cMacro 		:= ""
Local nAt1			:= 0
Local nAt2			:= 0

cQryMacro := cSqlProg

While (nAt1 := At("[",cQryMacro)) > 0 // Procura string dentro de Colchetes (express๕es)
	nAt2 		:= At("]",cQryMacro)
	cMacro 	:= SubStr(cQryMacro,nAt1+1, (nAt2-nAt1)-1) 
	cQryMacro 	:= StrTran(cQryMacro, "["+cMacro+"]", &(cMacro))
EndDo  

Return(cQryMacro)
//---------------------------------------------------------------------------
//GetCposRet - Retorno os campos do SELECT de retorno						   |
//---------------------------------------------------------------------------
Static Function GetCposRet(cSqlProg)
Local nAt1			:= 0 // Posi็ใo da string inicio
Local nAt2			:= 0 // Posi็ใo da string fim
Local cCpos		:= ""
Local cAux			:= cSqlProg

If (nAt1 := At("SELECT",Upper(cAux))) > 0
	nAt1 := nAt1 +6
	//cAux := SubStr(cAux, nAt1+6, Len(cAux))
	If (nAt2 := At("FROM",Upper(cAux))) > 0
		cCpos := SubStr(cAux, nAt1, (nAt2-nAt1) -1)
	EndIf
	// Concatena os asteriscos para substitui-los no final
	cSqlProg := Alltrim(SubStr(cAux, 1, nAt1)) + "***  " + Chr(10)+Chr(13)+ SubStr(cAux, nAt2, Len(nAt2)) // Altera a SELECT pra retirar os campos 
EndIf

Return(cCpos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSRTVID   บAutor  ณMicrosiga           บ Data ณ  10/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLSRTVID(cPacien)
Local cmativ	:=	"" 
Local aArea		:= getArea()

Default	cPacien	:=	""

DbSelectArea("GBH")
DbSetOrder(1) //GBH_FILIAL + GBH_CODPAC
DbSeek(xFilial("GBH") + cPacien)
                         
If HS_EXISDIC({{"C", "GBH_MATVID"}},.F.) .AND. !Empty(GBH->GBH_MATVID)
	Return(GBH->GBH_MATVID)
EndIf


DbSelectArea("GD4")
DbSetOrder(2) //Gd4_FILIAL + GD4_REGGER
DbSeek(xFilial("GD4") + GBH->GBH_CODPAC+"1" )

Hs_TabPLS("A",xFilial("BA1"), .T.)

DbSelectArea("BA1")
BA1->(DbSetOrder(2))
BA1->(MsSeek(xFilial("BA1")+GD4->GD4_MATRIC))

	DbSelectArea("BTS")
	DbSetOrder(1)
	DbSeek(xFilial("BTS")+BA1->BA1_MATVID)

cMativ:=BTS->BTS_MATVID  


Hs_TabPLS("F",xFilial("BA1"), .T.)

RestArea(aArea)

Return(cMativ)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSRTGBH   บAutor  ณMicrosiga           บ Data ณ  10/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLSRTGBH(cMatVid)
Local cCarteirinha := "" // Carteirinha do paciente BA1

If HS_EXISDIC({{"C", "GBH_MATVID"}},.F.) .AND. !Empty(GBH->GBH_MATVID)
	DbSelectArea("GBH")
	DbSetOrder(8) //GBH_FILIAL + GBH_MATVID
	DbSeek(xFilial("GBH") + cMatVid)
	Return(GBH->GBH_CODPAC)
EndIf

BA1->(DbSetOrder(7))
If BA1->(MsSeek(xFilial("BA1")+cMatVid))
	cCarteirinha := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
	GD4->(DbSetOrder(3)) // GD4_FILIAL+GD4_MATRIC+GD4_CODPLA
	If GD4->(MsSeek(xFilial("GD4") + cCarteirinha))
		Return(GD4->GD4_REGGER)
	Else
		If BA1->(MsSeek(xFilial("BA1")+cMatVid)) // Faz o seek no proximo caso exista mais de 1 BA1
			cCarteirinha := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
			If GD4->(MsSeek(xFilial("GD4") + cCarteirinha))
				Return(GD4->GD4_REGGER)
			EndIf
		EndIf
	EndIf
EndIf
Return("")

//--------------------------------------------------------------------------
//PSplitAdvpl - Funcao que retorna um array a partir de uma string de      |
// separacao conforme passo pelo parametro (similir Split JavaScript)      |
//--------------------------------------------------------------------------
Function PlSplitAdvpl(cString, cCharSep)
Local aArray	:= {}
Local cStrAtu	:= ""
Local nAt		:= 0
If SubStr(cString, 1,1) == cCharSep //remove caracter de separa็ใo no inicio
	cString := Alltrim(SubStr(cString, 2,Len(cString))) 
EndIf
If SubStr(cString, Len(cString),1) == cCharSep //remove caracter de separa็ใo no fim
	cString := Alltrim(SubStr(cString, 1,Len(cString)-1))
EndIf
While (nAt := At(cCharSep, cString)) > 0
	cStrAtu := Alltrim(SubStr(cString, 1,At(cCharSep, cString)-1 ))
	If !Empty(cStrAtu)
		AaDD(aArray,  Alltrim(SubStr(cString, 1,At(cCharSep, cString)-1 )))
	EndIf
	cString := Alltrim(SubStr(cString, At(cCharSep, cString)+1,Len(cString) ))
EndDo
Return(aArray)
//--------------------------------------------------------------------------
//PPrMenosDT - Retorna a data subtraida com os dias de acordo com o numero |
// passado por parametro 														  |
//--------------------------------------------------------------------------
Function PPrMenosDT(dData,nDiasMenos)
Local dDatRet			:= CTOD("")
Local nI				:= 0
Default dData 		:= dDataBase
Default nDiasMenos 	:= 30
dDatRet := dData
For nI := 1 To nDiasMenos
	dDatRet -- 
Next nI
Return("'"+DTOS(dDatRet)+"'")

//--------------------------------------------------------------------------
//PPrMaisDT - Retorna a data somada com os dias de acordo com o numero |
// passado por parametro 														  |
//--------------------------------------------------------------------------
Function PPrMaisDT(dData,nDiasMais)
Local dDatRet		:= CTOD("")
Local nI			:= 0
Default dData 		:= dDataBase
Default nDiasMais 	:= 30

dDatRet := dData    

For nI := 1 To nDiasMais
	dDatRet ++ 
Next nI

Return(DTOS(dDatRet))

//--------------------------------------------------------------------------
//PPROSINJOB - Funcao para ser executada em JOB que verificara os alertas  |
// automaticos inseridos na tabela BOS e enviara o mesmo					  |
//--------------------------------------------------------------------------
Function PPROSINJOB(cMatVid, cCodSin, cProgram)
Local cSql 	:= ""
Local aArea	:= getArea()

cSql := " SELECT BOS_CODSIN, BOS_VIDA, BOS_CODPRO, BOS_NROSEQ "
cSql += " FROM " + RetSqlName("BOS") + " BOS "
cSql += " WHERE BOS.BOS_AUTOMA = '1' AND BOS.BOS_STATUS = '0' AND BOS.BOS_DATSIN ='" + DTOS(dDataBase) + "'"
cSql  := ChangeQuery(cSql)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlProg),"QRYALE",.F.,.T.) 
DbSelectArea("QRYALE")
If !QRYALE->(Eof())
	While !QRYALE->(Eof())
		PMPROSIN(QRYALE->BOS_VIDA, QRYALE->BOS_CODSIN, QRYALE->BOS_CODPRO)
		BOS->(DbSetOrder(1))
		If BOS->(MsSeek(xFilial("BOS") + QRYALE->BOS_NROSEQ)) // ATRIBUI COMO PROCESSADO O ALERTA
			RecLock(.F.)
				BOS->BOS_STATUS := "1"
			MsUnlock()
		EndIf
		QRYALE->(DbSkip())
	EndDo
EndIf
DbSelectArea("QRYALE")
QRYALE->(DbCloseArea())
RestArea(aArea)
Return()
//--------------------------------------------------------------------------
//PPROINCPRO - Inclui participante elegivel no Programa						  |
//--------------------------------------------------------------------------
Function PPROINCPRO(cSeqEleg, cCrmResp,cCodProgr,cVida,cRisco, lInscrito,cStatus, cCodLoc)
Local aArea	 	:= GetArea()
Local nDias		:= 0
Local cSeqBOM		:= ""
Local nPosEleg		:= 0
Default cCrmResp	:= ""
Default cCodProgr	:= ""
Default	cSeqEleg	:= ""
Default cRisco		:= ""
Default lInscrito	:= .F.
Default cCodLoc		:= "" 
Default cStatus		:=""

 
	BOM->(DbSetOrder(2))
	If  Empty(cCodProgr) .And. BOM->(MsSeek(xFilial("BOM") +cSeqEleg))
		BOA->(DbSetOrder(1))
		BOA->(MsSeek(xFilial("BOA") +BOM->BOM_CODPRO))
		If  cStatus $ "02" 
	   		If FunName() == 'PLSMPROM'
				cStatus := "1"
			EndIf

		GBJ->(DbSetOrder(1))
		GBJ->(MsSeek(xFilial("GBJ") +cCrmResp))
		cLocal:= IIf(Empty(cCodLoc),substr(GBJ->GBJ_RDALOC,4,3), cCodLoc)
		
		RecLock("BOM", .F.)
		BOM->BOM_STATUS 	:= cStatus //"1" // INSCRITO
		BOM->BOM_DTINSC 	:= dDataBase
		BOM->BOM_LOGARQ	    := HS_LOGARQ()
		BOM->BOM_CODLOC	    := cLocal
		If !Empty(cCrmResp)
			BOM->BOM_MEDRSP := cCrmResp
		EndIf
		If !Empty(BOA->BOA_DATFIM)
			BOM->BOM_DATINI := dDataBase
			BOM->BOM_DATFIM := BOA->BOA_DATFIM
		Else
			If BOA->BOA_DURACA == "0" //Dias
				nDias := BOA->BOA_CTRDUR
			ElseIf BOA->BOA_DURACA == "1"//semana
				nDias := (BOA->BOA_CTRDUR * 7)
			ElseIf BOA->BOA_DURACA == "2" // Mes
				nDias := (BOA->BOA_CTRDUR * 30)
			Else // Ano
				nDias := (BOA->BOA_CTRDUR * 365)
			EndIf
			
			BOM->BOM_DATINI := dDataBase
			BOM->BOM_DATFIM := STOD(PPrMaisDT(dDataBase,nDias))
		EndIf
		
		MsUnlock()
		BOM->(MsSeek(xFilial("BOM") +cSeqEleg))
		PLSPRO05(BOM->BOM_VIDA,cSeqEleg,BOM->BOM_CODPRO,"",BOM->BOM_STATUS) //CRIA PLANEJAMENTO
		Else
			MsgInfo("O paciente nใo pode ser Inscrito Verifique o Status no Programa  ")
		Endif
        
	ElseIf FunName() == 'HSPAHMA7'
		
		nPosEleg := Ascan(oGetBOM:aHeader,{|x| Alltrim(x[2])=="BOM_NROSEQ"})
		cSeqEleg := oGetBOM:acols[oGetBOM:nAt][nPosEleg]
		
		If !Empty(cSeqEleg) .AND. BOM->(MsSeek(xFilial("BOM") +cSeqEleg)) .AND. cCodProgr == BOM->BOM_CODPRO
			If BOM->BOM_STATUS == '0' //.Or. BOM->BOM_STATUS == '2'
				
				BOA->(DbSetOrder(1))
				BOA->(MsSeek(xFilial("BOA") +BOM->BOM_CODPRO))
				GBJ->(DbSetOrder(1))
				GBJ->(MsSeek(xFilial("GBJ") +cCrmResp))
				cLocal:= IIf(Empty(cCodLoc),substr(GBJ->GBJ_RDALOC,4,3), cCodLoc)
				
				RecLock("BOM", .F.)
				BOM->BOM_STATUS  := "1" // INSCRITO
				BOM->BOM_DTINSC  := dDataBase
				BOM->BOM_LOGARQ	 := HS_LOGARQ()
				BOM->BOM_CODLOC	    := cLocal
				If !Empty(cCrmResp)
					BOM->BOM_MEDRSP := cCrmResp
				EndIf
				If !Empty(BOA->BOA_DATFIM)
					BOM->BOM_DATINI := dDataBase
					BOM->BOM_DATFIM := BOA->BOA_DATFIM
				Else
					If BOA->BOA_DURACA == "0" //Dias
						nDias := BOA->BOA_CTRDUR
					ElseIf BOA->BOA_DURACA == "1"//semana
						nDias := (BOA->BOA_CTRDUR * 7)
					ElseIf BOA->BOA_DURACA == "2" // Mes
						nDias := (BOA->BOA_CTRDUR * 30)
					Else // Ano
						nDias := (BOA->BOA_CTRDUR * 365)
					EndIf
					
					BOM->BOM_DATINI := dDataBase
					BOM->BOM_DATFIM := STOD(PPrMaisDT(dDataBase,nDias))
				EndIf
				
				MsUnlock()
				BOM->(MsSeek(xFilial("BOM") +cSeqEleg))
				PLSPRO05(BOM->BOM_VIDA,cSeqEleg,BOM->BOM_CODPRO,"",cStatus) //CRIA PLANEJAMENTO
			ElseIf BOM->BOM_STATUS == '2' //concluido inclui outro registro
				
				BOA->(DbSetOrder(1))
				BOA->(MsSeek(xFilial("BOA") +cCodProgr))
				GBJ->(DbSetOrder(1))
				GBJ->(MsSeek(xFilial("GBJ") +cCrmResp))
				cLocal:= IIf(Empty(cCodLoc),substr(GBJ->GBJ_RDALOC,4,3), cCodLoc)
				Reclock("BOM",.T.)
				BOM->BOM_FILIAL 	:= xFilial("BOM")
				BOM->BOM_CODPRO 	:= cCodProgr
				BOM->BOM_VIDA 	    := cVida
				BOM->BOM_NOME 	    := Posicione("BTS",1,xFilial("BTS") + cVida, "BTS_NOMUSR")
				BOM->BOM_DTELEG 	:= dDataBase
				If !Empty(cCrmResp)
					BOM->BOM_MEDRSP 	:= cCrmResp
				Endif
				BOM->BOM_STATUS 	:= IIf(lInscrito, "1","0") // Elegivel/inscrito
				If lInscrito
					BOM->BOM_DTINSC 	:= dDataBase
					BOM->BOM_LOGARQ	:= HS_LOGARQ()
					If !Empty(BOA->BOA_DATFIM)
						BOM->BOM_DATINI := dDataBase
						BOM->BOM_DATFIM := BOA->BOA_DATFIM
					Else
						If BOA->BOA_DURACA == "0" //Dias
							nDias := BOA->BOA_CTRDUR
						ElseIf BOA->BOA_DURACA == "1"//semana
							nDias := (BOA->BOA_CTRDUR * 7)
						ElseIf BOA->BOA_DURACA == "2" // Mes
							nDias := (BOA->BOA_CTRDUR * 30)
						Else // Ano
							nDias := (BOA->BOA_CTRDUR * 365)
						EndIf
						
						BOM->BOM_DATINI := dDataBase
						BOM->BOM_DATFIM := STOD(PPrMaisDT(dDataBase,nDias))
					EndIf
				EndIf
				BOM->BOM_GRARIS 	:= cRisco
				BOM->BOM_ORIGEM 	:= FunName() // Rotina de origem
				BOM->BOM_USUARI 	:= cUserName // Usuario logado
				BOM->BOM_LOGARQ 	:= Hs_LogArq() // Usuario logado
				BOM->BOM_NROSEQ 	:= cSeqBOM := GetSXENUM('BOM','BOM_NROSEQ',, 1)
				//BOM->BOM_VIP		:= IIf(Empty(TRBTMP->BA1_USRVIP), "0",TRBTMP->BA1_USRVIP)//PLSRetVIP(TRBTMP->BTS_MATVID)//BA1_USRVIP
				BA1->(DbSetOrder(7))
				If BA1->(MsSeek(xFilial("BA1") + cVida))
					BOM->BOM_VIP		:= IIf(Empty(BA1->BA1_USRVIP), "0",BA1->BA1_USRVIP)//PLSRetVIP(TRBTMP->BTS_MATVID)//BA1_USRVIP
				Else
					BOM->BOM_VIP		:= "0"
				EndIf
				BOM->BOM_MOTELE	    := "Incluido pelo Profissional de Saude durante o Atendimento "//PlRetMBOC(TRBTMP->BOC_ITECND)
				BOM->BOM_CODLOC	    := cLocal
				MsUnlock()
				ConfirmSx8()
				
				PLSPRO05(cVida,cSeqBOM,cCodProgr) //CRIA PLANEJAMENTO
			Else
				HELP('PLSFUNP',, 'PLSFUNP',, "Paciente nao e elegivel para que seja inscrito no mesmo!", 1, 0)	 //"Nใo foram encontrados novos elegiveis!"
			EndIf
		Else
			
			BOA->(DbSetOrder(1))
			BOA->(MsSeek(xFilial("BOA") +cCodProgr))
			GBJ->(DbSetOrder(1))
			GBJ->(MsSeek(xFilial("GBJ") +cCrmResp))
			cLocal:= IIf(Empty(cCodLoc),substr(GBJ->GBJ_RDALOC,4,3), cCodLoc)
			Reclock("BOM",.T.)
			BOM->BOM_FILIAL 	:= xFilial("BOM")
			BOM->BOM_CODPRO 	:= cCodProgr
			BOM->BOM_VIDA 	    := cVida
			BOM->BOM_NOME 	    := Posicione("BTS",1,xFilial("BTS") + cVida, "BTS_NOMUSR")
			BOM->BOM_DTELEG 	:= dDataBase
			If !Empty(cCrmResp)
				BOM->BOM_MEDRSP 	:= cCrmResp
			Endif
			BOM->BOM_STATUS 	:= IIf(lInscrito, "1","0") // Elegivel/inscrito
			If lInscrito
				BOM->BOM_DTINSC 	:= dDataBase
				BOM->BOM_LOGARQ	:= HS_LOGARQ()
				If !Empty(BOA->BOA_DATFIM)
					BOM->BOM_DATINI := dDataBase
					BOM->BOM_DATFIM := BOA->BOA_DATFIM
				Else
					If BOA->BOA_DURACA == "0" //Dias
						nDias := BOA->BOA_CTRDUR
					ElseIf BOA->BOA_DURACA == "1"//semana
						nDias := (BOA->BOA_CTRDUR * 7)
					ElseIf BOA->BOA_DURACA == "2" // Mes
						nDias := (BOA->BOA_CTRDUR * 30)
					Else // Ano
						nDias := (BOA->BOA_CTRDUR * 365)
					EndIf
					
					BOM->BOM_DATINI := dDataBase
					BOM->BOM_DATFIM := STOD(PPrMaisDT(dDataBase,nDias))
				EndIf
			EndIf
			BOM->BOM_GRARIS 	:= cRisco
			BOM->BOM_ORIGEM 	:= FunName() // Rotina de origem
			BOM->BOM_USUARI 	:= cUserName // Usuario logado
			BOM->BOM_LOGARQ 	:= Hs_LogArq() // Usuario logado
			BOM->BOM_NROSEQ 	:= cSeqBOM := GetSXENUM('BOM','BOM_NROSEQ',, 1)
			//BOM->BOM_VIP		:= IIf(Empty(TRBTMP->BA1_USRVIP), "0",TRBTMP->BA1_USRVIP)//PLSRetVIP(TRBTMP->BTS_MATVID)//BA1_USRVIP
			BA1->(DbSetOrder(7))
			If BA1->(MsSeek(xFilial("BA1") + cVida))
				BOM->BOM_VIP		:= IIf(Empty(BA1->BA1_USRVIP), "0",BA1->BA1_USRVIP)//PLSRetVIP(TRBTMP->BTS_MATVID)//BA1_USRVIP
			Else
				BOM->BOM_VIP		:= "0"
			EndIf
			BOM->BOM_MOTELE	    := "Incluido pelo Profissional de Saude durante o Atendimento "//PlRetMBOC(TRBTMP->BOC_ITECND)
			BOM->BOM_CODLOC	    := cLocal
			MsUnlock()
			ConfirmSx8()
			
			PLSPRO05(cVida,cSeqBOM,cCodProgr) //CRIA PLANEJAMENTO
		EndIf
	Else
		BOA->(DbSetOrder(1))
		BOA->(MsSeek(xFilial("BOA") +cCodProgr))
		GBJ->(DbSetOrder(1))
		GBJ->(MsSeek(xFilial("GBJ") +cCrmResp))
		cLocal:= IIf(Empty(cCodLoc),substr(GBJ->GBJ_RDALOC,4,3), cCodLoc)
		Reclock("BOM",.T.)
		BOM->BOM_FILIAL 	:= xFilial("BOM")
		BOM->BOM_CODPRO 	:= cCodProgr
		BOM->BOM_VIDA 	    := cVida
		BOM->BOM_NOME 	    := Posicione("BTS",1,xFilial("BTS") + cVida, "BTS_NOMUSR")
		BOM->BOM_DTELEG 	:= dDataBase
		If !Empty(cCrmResp)
			BOM->BOM_MEDRSP 	:= cCrmResp
		Endif
		BOM->BOM_STATUS 	:= IIf(lInscrito, "1","0") // Elegivel/inscrito
		If lInscrito
			BOM->BOM_DTINSC 	:= dDataBase
			BOM->BOM_LOGARQ	:= HS_LOGARQ()
			If !Empty(BOA->BOA_DATFIM)
				BOM->BOM_DATINI := dDataBase
				BOM->BOM_DATFIM := BOA->BOA_DATFIM
			Else
				If BOA->BOA_DURACA == "0" //Dias
					nDias := BOA->BOA_CTRDUR
				ElseIf BOA->BOA_DURACA == "1"//semana
					nDias := (BOA->BOA_CTRDUR * 7)
				ElseIf BOA->BOA_DURACA == "2" // Mes
					nDias := (BOA->BOA_CTRDUR * 30)
				Else // Ano
					nDias := (BOA->BOA_CTRDUR * 365)
				EndIf
				
				BOM->BOM_DATINI := dDataBase
				BOM->BOM_DATFIM := STOD(PPrMaisDT(dDataBase,nDias))
			EndIf
		EndIf
		BOM->BOM_GRARIS 	:= cRisco
		BOM->BOM_ORIGEM 	:= FunName() // Rotina de origem
		BOM->BOM_USUARI 	:= cUserName // Usuario logado
		BOM->BOM_LOGARQ 	:= Hs_LogArq() // Usuario logado
		BOM->BOM_NROSEQ 	:= cSeqBOM := GetSXENUM('BOM','BOM_NROSEQ',, 1)
		//BOM->BOM_VIP		:= IIf(Empty(TRBTMP->BA1_USRVIP), "0",TRBTMP->BA1_USRVIP)//PLSRetVIP(TRBTMP->BTS_MATVID)//BA1_USRVIP
		BA1->(DbSetOrder(7))
		If BA1->(MsSeek(xFilial("BA1") + cVida))
			BOM->BOM_VIP		:= IIf(Empty(BA1->BA1_USRVIP), "0",BA1->BA1_USRVIP)//PLSRetVIP(TRBTMP->BTS_MATVID)//BA1_USRVIP
		Else
			BOM->BOM_VIP		:= "0"
		EndIf
		BOM->BOM_MOTELE	    := "Incluido pelo Profissional de Saude durante o Atendimento "//PlRetMBOC(TRBTMP->BOC_ITECND)
		BOM->BOM_CODLOC	    := cLocal
		MsUnlock()
		ConfirmSx8()
		
		PLSPRO05(cVida,cSeqBOM,cCodProgr) //CRIA PLANEJAMENTO
		
	EndIf
RestArea(aArea)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSFOPRO   บAutor  ณMicrosiga           บ Data ณ  10/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ   Fun็ใo que vai exibir a Movimenta็ใo da Promo็ใo Saude    บฑฑ
ฑฑบ          ณ   no Prontuแrio 						                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHM57,HSPAHMA7                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function PLSFOPRO(aCord1,aCord2,aCord3,aCord4,oFolder,cGbhCodPac, cCodCrm, cCodLoc)

Local Matvid		:=	""

/*Local  oButtPr2 	:= nil
/*Local  oMenuPr2 	:= nil
Local  oMenuPr01 	:= nil
Local  oMenuPr02 	:= nil
Local  oMenuPr03 	:= nil
Local  oMenuPr04 	:= nil
Local  oMenuPr05 	:= nil
Local  oMenuPr06 	:= nil
Local  oMenuPr07 	:= nil
Local  oMenuPr08 	:= nil
Local  oMenuPr09 	:= nil
Local  oMenuPr1 	:= nil*/ 
Local aCpOrcAlt := {}

DEFAULT cGbhCodPac	:= ""
Default cCodCrm    	:= ""                                                              
Default cCodLoc    	:= ""

If !Empty(cCodLoc) .AND. Len(cCodLoc) == 2 // LOCAL NO HSP PARA LOCAL NO PLS
	cCodLoc := Posicione("GCS",1,xFilial("GCS") +  cCodLoc, "GCS_LOCPLS")
EndIf

aColsBOM	:={}

HS_BDados("BOM" , @aHeadBOM, @aColsBOM,        , 1   ,        , " BOM.BOM_VIDA = '" + cGbhCodPac + "' AND BOM_STATUS <> '2'  ",        ,"BOM_STATUS","/"     ,         ,        ,        ,        ,        ,        ,aLegBOM,        ,   .T.   ,           ,         , /*aCpoGcy*/,        ,          ,"BOM_CODPRO" )
nGetSTATUS 	:= aScan(aHeadBOM, {|aVet| aVet[2] == "BOM_STATUS"})
nGetCODPRO 	:= aScan(aHeadBOM, {|aVet| aVet[2] == "BOM_CODPRO"})
nGetVida 	:= aScan(aHeadBOM, {|aVet| aVet[2] == "BOM_VIDA  "})
nGetNroseq 	:= aScan(aHeadBOM, {|aVet| aVet[2] == "BOM_NROSEQ"})
nGetRISCO   := aScan(aHeadBOM, {|aVet| aVet[2] == "BOM_GRARIS"})

Aadd(aCpOrcAlt,"BOM_GRARIS")

//================================================================ฟ
//ณ Grid da Promo็ใo Da Saude   								 ณ
//================================================================ู
oGetBOM:= MsNewGetDados():New(aCord1, aCord2, aCord3*0.65/*240*/, aCord4/*605*/, GD_UPDATE,,,,aCpOrcAlt,,,,,, oFolder, aHeadBOM, aColsBOM) 
oGetBOM:bFIELDOk := {|| FS_ALTRIS(oGetBOM:oBrowse:nAt, nGetRISCO,nGetCODPRO,nGetVida,nGetNroseq)}
//oGetBOM:bChange := {|| PproHabBut(oGetBOM:aCols[oGetBOM:nAt, nGetSTATUS]),oMenuPr01,oMenuPr07 }         
oGetBOM:bChange := {|| PProCtrBut(oGetBOM:aCols[oGetBOM:nAt, nGetVida], oGetBOM:aCols[oGetBOM:nAt, nGetSTATUS], oGetBOM:aCols[oGetBOM:nAt, nGetCODPRO]) }
//oGetBOM:oBrowse:bGotFocus := {|| PProCtrBut(oGetBOM:aCols[oGetBOM:nAt, nGetVida], oGetBOM:aCols[oGetBOM:nAt, nGetSTATUS], oGetBOM:aCols[oGetBOM:nAt, nGetCODPRO]) }

//================================================================ฟ
// cria os menus
//================================================================ฟ

oMenuPr2 := tMenu():new(0, 0, 0, 0, .T., , oMenuPr1)

//================================================================ฟ
// cria os itens dos menus
//================================================================ฟ

oMenuPr01 := tMenuItem():new(oMenuPr2, "Inclui no Programa ", , , , {|| PPROPROIN(oGetBOM:aCols[oGetBOM:nAt, nGetNroseq], cCodCrm,PLSRTVID(GBH->GBH_CODPAC)/*oGetBOM:aCols[oGetBOM:nAt, nGetVida]*/,oGetBOM:aCols[oGetBOM:nAt, nGetCODPRO],oGetBOM, cCodLoc)}, , , , , , , , , .T.)
oMenuPr02 := tMenuItem():new(oMenuPr2, "Banco Conhe. Prog.  ", , , , {|| PRO90BCO(1)}, , , , , , , , , .T.)
oMenuPr03 := tMenuItem():new(oMenuPr2, "Relat๓rio", , , , {|| "Funcao"}, , , , , , , , , .T.)
//oMenuPr04 := tMenuItem():new(oMenuPr2, "Grafico Indivi", , , , {||PLSPROGRA(oGetBOM:aCols[oGetBOM:nAt, nGetCODPRO]) }, , , , , , , , , .T.)
oMenuPr05 := tMenuItem():new(oMenuPr2, "Legenda", , , , {||PLSPROLEG()}, , , , , , , , , .T.)
oMenuPr06 := tMenuItem():new(oMenuPr2, "Alta", , , , {|| PLSPROALT(oGetBOM:aCols[oGetBOM:nAt, nGetNroseq])}, , , , , , , , , .T.)
//oMenuPr07 := tMenuItem():new(oMenuPr2, "Planejamento", , , , {||PLSPROPLA(oGetBOM:aCols[oGetBOM:nAt, nGetNroseq])  }, , , , , , , , , .T.) 
oMenuPr07 := tMenuItem():new(oMenuPr2, "Planejamento", , , , {||PLSPRO05(oGetBOM:aCols[oGetBOM:nAt, nGetVida],oGetBOM:aCols[oGetBOM:nAt, nGetNroseq],oGetBOM:aCols[oGetBOM:nAt, nGetCODPRO]) }, , , , , , , , , .T.)
//oMenuPr07 := tMenuItem():new(oMenuPr2, "Eventos Partici", , , , {|| PProEventP()/*PLSEVENTO(oGetBOM:aCols[oGetBOM:nAt, nGetNroseq])*/}, , , , , , , , , .T.)
oMenuPr08 := tMenuItem():new(oMenuPr2, "Alertas/Trat. Sugerido", , , , {|| PLSPROEXAL(oGetBOM:aCols,oGetBOM:aCols[oGetBOM:nAt, nGetCODPRO], oGetBOM:aCols[oGetBOM:nAt, nGetVida], nGetCODPRO,oGetBOM:aCols[oGetBOM:nAt, nGetRISCO],nGetRISCO)}, , , , , , , , , .T.)
oMenuPr09 := tMenuItem():new(oMenuPr2, "Perfil do Contato ", , , , {|| PLSPROCAM(oGetBOM:aCols[oGetBOM:nAt, nGetVida])}, , , , , , , , , .T.)
oMenuPr10 := tMenuItem():new(oMenuPr2, "Movimenta็๕es Paciente ", , , , {|| PLSPROAUT(oGetBOM:aCols[oGetBOM:nAt, nGetVida], GBH->GBH_CODPAC)}, , , , , , , , , .T.)
oMenuPr11 := tMenuItem():new(oMenuPr2, "Alterar Grau de Risco ", , , , {|| PMPRORISCO(oGetBOM:aCols[oGetBOM:nAt, nGetVida],oGetBOM:aCols[oGetBOM:nAt, nGetCODPRO])}, , , , , , , , , .T.)
oMenuPr12 := tMenuItem():new(oMenuPr2, "Historico de Risco/Setor ", , , , {|| PMPROHIST(oGetBOM:aCols[oGetBOM:nAt, nGetNroseq])}, , , , , , , , , .T.)
oMenuPr2:add(oMenuPr01)
oMenuPr2:add(oMenuPr02)
oMenuPr2:add(oMenuPr03)
//oMenuPr2:add(oMenuPr04)
oMenuPr2:add(oMenuPr05)
oMenuPr2:add(oMenuPr06)
oMenuPr2:add(oMenuPr07)
oMenuPr2:add(oMenuPr08)
oMenuPr2:add(oMenuPr09)
oMenuPr2:add(oMenuPr10)
oMenuPr2:add(oMenuPr11)
oMenuPr2:add(oMenuPr12)

oMenuPr03:lActive := .F.
oButtPr2 := tButton():New(aCord3*0.75, 10, "Op็๕es", oFolder, {|| }, 050, 010,,,, .T.)
oButtPr2:setPopupMenu(oMenuPr2)

Return()
//---------------------------------------------------------------------
// HABILITA E DESABILITA OPวีES DE ACORDO COM O STATUS E DADOS DO GRID 
//---------------------------------------------------------------------  
Static Function PProCtrBut(cVida, cStProg, cCodPro)
//Static Function PproHabBut(cStatus,oMenuPr01,oMenuPr07) 

/*If !Empty(cVida) 
	DbSelectArea("BOA")
	BOA->(MsSeek(xFilial("BOA") + cCodPro))  //Posiciona no programa para o Bco de Conhecimento
*/	oMenuPr07:lActive := .T. //Enable() 
	oMenuPr02:lActive := .T. // Enable()
	oMenuPr08:lActive := .T.
/*Else
	oMenuPr07:lActive := .F. //Disabled()
	oMenuPr02:lActive := .F. //Disabled()
	oMenuPr08:lActive := .F. 
EndIf       */

If "AMARELO" $ cStProg .OR. "VERMELHO" $ cStProg //ALTA
	oMenuPr06:lActive := .T. //Enable()
	oMenuPr07:lActive := .T. //Enable() 
Else    
	oMenuPr06:lActive := .F. //Disabled()
	oMenuPr07:lActive := .F. //Enable()	
EndIf 

//If "AZUL" $ cStProg //INCLUI NO PROGRAMA
//	oMenuPr01:lActive := .T.// Enable() 
//Else    
//	oMenuPr01:lActive := .F. //Disabled()
//EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSFOREFR   บAutor  ณMicrosiga           บ Data ณ  10/04/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Refresh das informa็oes do Paciente na Promo็ใo Saude      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function PLSFOREFR(cGbhCodPac,lVid)
Default  lVid:=.F.

//================================================================ฟ
//ณ Busco a Vida   								 ณ
//================================================================ู

If !Empty(cGbhCodPac) .and. !lVid
	Matvid:=PLSRTVID(cGbhCodPac)
Else
	Matvid:= cGbhCodPac
Endif
aColsBOM:={}
aHeadBOM:={}

HS_BDados("BOM" , @aHeadBOM, @aColsBOM,        , 1   ,        , " BOM.BOM_VIDA = '" + Matvid + "' AND BOM_STATUS <> '2' ",        ,"BOM_STATUS","/"     ,         ,        ,        ,        ,        ,        ,aLegBOM,        ,   .T.   ,           ,         , /*aCpoGcy*/,        ,          ,"BOM_CODPRO" )
nGetCODPRO := aScan(aHeadBOM, {|aVet| aVet[2] == "BOM_CODPRO"})
oGetBOM:setArray(aColsBOM)
oGetBOM:oBrowse:Refresh()
oGetBOM:oBrowse:SetFocus()

Return()



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHSPAHMLEG ณ Autor ณ				   	    ณ Data ณ03/10/2012ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Define as Legendas utilizadas na Promo็ใo da Sa๚de         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ PLSPRLEG()                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ HSPAHM57,HSPAHMA7                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function PLSPROLEG()
Local aLegenda := {}
Aadd(aLegenda,{"BR_AZUL"   		, "Paciente Elegivel"})  
Aadd(aLegenda,{"BR_AMARELO"     , "Paciente Inscrito"}) 
Aadd(aLegenda,{"BR_VERDE"     	, "Programa concluํdo"}) 
Aadd(aLegenda,{"BR_VERMELHO"   	, "Possui Pendencias"}) 
Aadd(aLegenda,{"BR_CINZA"  		, "Cadastro Bloqueado"}) 

BrwLegenda("Promo็ใo da Sa๚de","Promo็ใo da Sa๚de",aLegenda)  //"Agendamento" ### "Plano de Tratamento"

Return(aLegenda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSPROALT   บAutor  ณMicrosiga         บ Data ณ  10/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a Alta da promo็ใo Sa๚de                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function PLSPROALT(cSeqPro)
Local cTipoAlta
Local lvid := .T.

If !Pergunte("PMPRO03",.T.)
	Return()
EndIf

cTipoAlta := MV_PAR01

If Empty(cTipoAlta)       
	MsgInfo("Tipo de alta nao informado!")
	Return()
EndIf

BOM->(DbSetOrder(2))
If BOM->(MsSeek(xFilial("BOM") + cSeqPro))
	If BOM->BOM_STATUS == '1' .Or. BOM->BOM_STATUS == '3'
	BOM->(RecLock("BOM",.F.))
	BOM->BOM_STATUS	 := "2"
	BOM->BOM_DATALT := DATE()
	BOM->BOM_MOTALT	:= cTipoAlta
   //	BOM->BOM_DESMOT	:= HS_IniPadr("GF4", 1, cTipoAlta, "GF4_DSTPAL")
   BOM->(MsUnLock())                                 
   //Exclui planejamento futuro e em aberto
   FS_EXCPLAN(BOM->BOM_VIDA,cSeqPro)
	Else
	   MsgInfo("Para que seja possivel dar alta ao paciente ele deve estar Inscrito no Programa ou possuir Pendencias.")
	EndIf   
ELSE
	MsgInfo("Nใo foi Selecionado Nenhum Paciente da Promo็ใo Da Saude ")
Return()
EndIf

If ("HSPAHM24" $ FUNNAME() .OR. "HSPAHM57" $ FUNNAME() .OR. "HSPAHMA7" $ FUNNAME())
	PLSFOREFR(BOM->BOM_VIDA,lvid)
Endif

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSPROGRA   บAutor  ณMicrosiga           บ Data ณ  10/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLSPROGRA(cCodPro)
Local cCInd:=""    

BOA->(DbSetOrder(1))
If BOA->(MsSeek(xFilial("BOA") + cCodPro))
	cCInd:=BOA->BOA_INDIND
	PProMntGraf(cCInd)
ELSE
	MsgInfo("Nenhum Grafico encontrado ")
	Return()
	
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPProMntGraf  บAutor  ณMicrosiga        บ Data ณ  10/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
 
Function PProMntGraf(cCodInd ,aDados, cTipo, cTitulo,lSini,aTitulo,cNome,cProgram,dData)
Local  	nRecP1		:=	0
Local  	aPnl1		:=	{}
local 	oGraph
LOCAL 	oDlgGraph
Local oFwLayerAux
Local nI			:= 0
Local oPGraph 
Local aSize := FWGetDialogSize( oMainWnd )
Local aInfo      :={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aDadGraf := {}
Local aObjects := {}
Local nj	:=0
Local oPGrapI
Local aReceita	:={}
Local aCustos	:={}
Local aSinistro	:={}
Local aSinistro1	:={}
/**/
default cCodInd		:=	""
Default aDados    	:= {}
Default cTipo		:= ""
Default cTitulo		:= ""
Default lSini		:=.F.
Default aTitulo		:={}
Default cNome		:=""
Default cProgram	:=""
Default dData		:=""

AADD(aObjects,{100,015,.T.,.F.,.F.})
AADD(aObjects,{100,100,.T.,.T.,.T.})
AADD(aObjects,{100,015,.T.,.F.,.F.})
aPosObj:=MsObjSize(aInfo,aObjects)
  
If !lSini
	DEFINE MSDIALOG oDlgGraph TITLE cTitulo	FROM aSize[1]/2, aSize[2]/2 TO aSize[3]/2, aSize[4]/2 PIXEL  //"Movimenta็ใo Promo็ใo เ Sa๚de"
Else
	DEFINE MSDIALOG oDlgGraph TITLE cTitulo	FROM aSize[1], aSize[2] TO aSize[3], aSize[4] PIXEL  //"Movimenta็ใo Promo็ใo เ Sa๚de"
Endif

oFwLayerAux := FwLayer():New()
oFwLayerAux:Init(oDlgGraph,.F.)
If !lSini
	oFwLayerAux:addLine("All", 100, .F.) //layer do meio Folders e Browse de Elegiveis
	oFwLayerAux:addCollumn( "Graph",100, .T. , "All") 	//Coluna Grid dos Programas
	oFwLayerAux:addCollumn( "Botoes",30, .T. , "All") 	//Coluna Grid dos Botoes
	oFwLayerAux:addCollumn( "Imprimir",35, .T. , "All")
	oPGraph	:= oFwLayerAux:GetColPanel( "Graph", "All" ) // Objeto Panel central 
	oPBotao	:= oFwLayerAux:GetColPanel( "Botoes", "All" ) // Objeto dio Botใo
Else 
	oFwLayerAux:addLine("LinAux0", 10, .F.) //Folder Superior
	oFwLayerAux:addLine("LinAux1", 45, .F.) //Folder Meio
	oFwLayerAux:addLine("LinAux2", 45, .F.) //Folder Inferior
	oFwLayerAux:addCollumn( "Texto",100, .T. , "LinAux0") 	//Coluna Grid dos Programas
	oFwLayerAux:addCollumn( "Graph",100, .T. , "LinAux1") 	//Coluna Grid dos Programas
	oFwLayerAux:addCollumn( "Botoes",100, .T. , "LinAux2") 	//Coluna Grid dos Botoes
	oFwLayerAux:addCollumn( "Imprimir",35, .T. , "LinAux2")
	oPGrapI	:= oFwLayerAux:GetColPanel( "Texto", "LinAux0" ) // Objeto Panel central
	oPGraph	:= oFwLayerAux:GetColPanel( "Graph", "LinAux1" ) // Objeto Panel central
	oPBotao	:= oFwLayerAux:GetColPanel( "Botoes", "LinAux2" ) // Objeto dio Botใo

Endif


If !Empty(cCodInd)
	DbSelectArea("GTA")
	DbSetOrder(1)
	If DbSeek(xFilial("GTA")  + cCodInd) .AND. Alltrim(GTA->GTA_TIPOIN) $ "23"
		nRecP1 := GTA->(Recno())
		aPnl1 := HSPPO020(nRecP1, .F.)                      
		If GTA->GTA_TIPOIN == "2"
		   	oGraph := FWChartPie():New()
		Else
		   	oGraph := FWChartBar():New()		   	
		EndIf
	   	oGraph:init( oPGraph, .T. ,.T.)  
	   	
		For nI := 1 to Len(aPnl1[3,1])
			oGraph:addSerie( Substr(Alltrim(aPnl1[3,1,nI]),1,12), aPnl1[5,1,nI] )  
			oGraph:SetTitle(Alltrim(GTA->GTA_TITULO),1 )
		Next nI
			
		oGraph:SetLegend( CONTROL_ALIGN_LEFT ) 
		oGraph:Build()			
	EndIf
	

ElseIf Len(aDados) > 0
	If !lSini
	If cTipo == "2"
		oGraph := FWChartPie():New()
	Else
		oGraph := FWChartBar():New()
	EndIf
	oGraph:init( oPGraph, .T. ,.T.)
	
	For nI := 1 to Len(aDados)
		oGraph:addSerie(DTOC(STOD(aDados[nI,1])), aDados[nI,2])
		oGraph:SetTitle(Alltrim(cTitulo),1 )
	Next nI
	oGraph:setLegend( CONTROL_ALIGN_LEFT )
	oGraph:Build()			
	Else
    	If !Empty(cNome)
			@ 010,010 SAY oSay PROMPT OemToAnsi(" Nome do paciente") SIZE 120,009 OF oPGrapI PIXEL COLOR CLR_BLUE
			@ 010,100 SAY oSay PROMPT cNome SIZE 120,009 OF oPGrapI PIXEL COLOR CLR_BLUE
		Endif	
		@ 020,010 SAY oSay PROMPT OemToAnsi(" Programa da Promo็ใo") SIZE 120,009 OF oPGrapI PIXEL COLOR CLR_BLUE //" Programa da Promo็ใo"
		@ 020,100 SAY oSay PROMPT cProgram SIZE 120,009 OF oPGrapI PIXEL COLOR CLR_BLUE
		@ 030,010 SAY oSay PROMPT OemToAnsi(" Data inscri็ใo") SIZE 120,009 OF oPGrapI PIXEL COLOR CLR_BLUE//" Data inscri็ใo"
		@ 030,100 SAY oSay PROMPT dData SIZE 120,009 OF oPGrapI PIXEL COLOR CLR_BLUE
		
		For nj:=1 to Len(aDados)
			If nj==1
				oGraph := FWChartBarComp():New()
		   Else
				oGraph := FWChartBar():New()
			Endif
			oGraph:init( Iif(nj=1,oPGraph,oPBotao), .T. ,.T.)
			If Len(aDados[1,1]) = 0
				Return()
			EndIf
			If nj==1
			For nI := 1 to Len(aDados[nj,1])

					If aDados[nj,1,nI,4] ==1 //nI < 13
						AADD( aReceita , {alltrim(aDados[nj,1,nI,1]),val(StrTran(aDados[nj,1,nI,2],".",""))})
					ElseIf aDados[nj,1,nI,4] ==2 
						AADD( aCustos , {alltrim(aDados[nj,1,nI,1]),val(StrTran(aDados[nj,1,nI,2],".",""))})
					Endif	
			Next nI	

			Else
			For nI := 1 to Len(aDados[nj])		
				 oGraph:addSerie(alltrim(aDados[nj,nI,1]), val(StrTran(aDados[nj,nI,2],".","")))	
			Next nI
			Endif
			If nJ == 1
				oGraph:addSerie("Receitas" , aReceita)//"Receitas"
				oGraph:addSerie("Custos", aCustos)//"Custos"
				oGraph:SetTitle(Alltrim(aTitulo[nj,1]),1 )
				oGraph:setLegend( CONTROL_ALIGN_LEFT )
				oGraph:Build()

			Else 
				oGraph:SetTitle(Alltrim(aTitulo[nj,1]),1 )
				oGraph:setLegend( CONTROL_ALIGN_LEFT )
				oGraph:Build()				


			EndIf
		Next nj
                        
	EndIf
	
Endif
Activate MsDialog oDlgGraph Centered  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSPROCAM  บAutor  ณMicrosiga           บ Data ณ  10/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSPROCAM(cMativd)
Local cContato	:=""

Private P_TMK_ENCERRADOS := "ENCERRADOS" // 4
Private P_UNDEF:=				"INDEFINIDO" // Paineis indefinidos nใo afetam regra de negocio
Private P_TMK_ATIVOS:=			"ATIVOS" // 5
Private P_TMK_RECEPTIVOS:=		"RECEPTIVOS" //6
Private P_TMK_FOLLOW:=			"FOLLOW" //7
Private P_TMK_PENDENCIAS:=		"PENDENCIAS" //8
Private P_TMK_CHAMADO:=		"CHAMADOS" //9
Private P_TMK_ATEND:=			"ATENDIMENTOS" //10


Private  P_CAMP:=				"CAMPANHA"//11
Private P_CAMP_ANSCRIPT:=		"ANSCRIPT"//13

Private P_TLV_ORCAMENTO:=		"ORวAMENTOS"//16
Private P_TLV_FATURAMENTO:=	"FATURAMENTO" //17
Private P_TLV_CANCELADO:=		"CANCELADO" //18
Private P_TLV_SIGALOJA:=		"SIGALOJA" //19
Private P_TLV_BONUS:=			"BONUS" //20

Private P_TLC_NEGOCIA:=		"NEGOCIACAO" //26
Private P_TLC_OCORR:=			"OCORRENCIAS" //27
Private P_TLC_VENCIDA:=		"VENCIDAS"//28

Private P_ANF_VENCIDO:=		"VENCIDOS"//31
Private P_ANF_VENCER:=			"AVENCER"//32
Private P_ANF_ATRASO:=			"ATRASO"//33
Private P_ANF_CARTORIO:=		"CARTORIO"//34
Private P_ANF_PROTESTADO:=		"PROSTESTADO"//35

Private P_ANF_NCC:=				"NCCSABERTO" //37

Private P_CONT_RESULTADO:=		"LSTRESULTADO" //42 que devia ser 46

Private P_VAR:=					"VAREJO"
Private P_VAR_REGDES:=			"REGRADESC"
Private P_VAR_VPERDIDA:=		"VENDAPERDIDA"
Private P_VAR_CARTAO:=			"CARTAOFIDEL"


If  empty(cMativd)
	MsgInfo("Nใo foi Selecionado Nenhum Paciente da Promo็ใo Da Saude ")
Else
	
	DBSELECTAREA("BA1")
	BA1->(DbSetOrder(7))
	If BA1->(MsSeek(xFilial("BA1") + cMativd))
		cContato := PlsCodContato(BA1->(BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO),"BA1")
		If Empty(cContato)
			cContato := PlsCodContato(BA1->(BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPUSU + BA1_TIPREG + BA1_DIGITO),"BA1")
	   	EndIf
		
		TK010Con("SU5" ,SU5->(RECNO()),2   ,      ,cContato       ,"BA1",BA1->(BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPUSU + BA1_TIPREG + BA1_DIGITO))
	Endif
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSPROEXAL  บAutor  ณMicrosiga           บ Data ณ  10/09/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe os Alertas do Programa Saude                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLSPROEXAL(aCBOM,cCodProg, cMatVid, nPosGD,cRisco,nPosRisc)
Local aArea   := getArea()
//local cAlias	:=	""

LOCAL aHeadBOF	:=	{}
LOCAL aColsBOF	:=	{}
LOCAL oBOF     
LOCAL aLegBOF	:=	{}       
Local cFilterBOF:=	""

LOCAL aHeadBOE	:=	{}
LOCAL aColsBOE	:=	{}
LOCAL aCpoBOE		:= {"BOE_CODPRO","BOE_ITEM", "BOE_TRATAM", "BOE_RISCO"}
LOCAL oBOE 
LOCAL aLegBOE	:=	{}
Local cFilterBOE:=	""

LOCAL aHeadBOS	:=	{}
LOCAL aColsBOS	:=	{}
LOCAL oBOS
LOCAL aLegBOS	:=	{}
Local cFilterBOS:=	""

//lOCAL aPPanel	:=	{}  
LOCAL ODLGALER
LOCAL nCont		:=	0
//LOCAL cCodProdu	:=	""
Local cRiscoAux	:= "  "
Local cVidAux 	:= "      "

Default aCBOM	:= 	{}
Default cCodProg:=	"      "  
Default cMatVid	:=	"      "
Default nPosGD	:= 0
Default nPosRisc :=0
Default cRisco:="  "
If Len(aCBOM) > 0
	cCodProg:="      "
	cRisco	:="  "
Endif

dbSelectArea("BOM")
dbSetOrder(3)
If BOM->(dbSeek(xFilial("BOM")+cMatVid))
	
	//FILTRO BOS
	cFilterBOS 	:= "BOS_FILIAL = '" + xFilial("BOS") + "' "
	
	//FILTRO BOF
	
	cFilterBOF 	:= "BOF_FILIAL = '" + xFilial("BOF") + "' "
	
	//FILTRO BOE
	
	cFilterBOE 	:= "BOE_FILIAL = '" + xFilial("BOE") + "' "
	
	If TYPE(cRisco)=="N"
		cRiscoAux:="'" + cRisco+ "'"
		cRisco:=cRiscoAux
	Endif
	
		If TYPE(cMatVid)=="N"
		cVidAux:="'" + cMatVid+ "'"
		cMatVid:=cVidAux
	Endif
	//Localizo Todos os Produtos
	If Len(aCBOM) > 0
		For nCont := 1 To Len(aCBOM)
			cCodProg += IIF(!EMPTY(cCodProg), ",", "") +  "'" + aCBOM[nCont, nPosGD]+ "'"
			cRisco += IIF(!EMPTY(cRisco), ",", "") +  "'" + aCBOM[nCont, nPosRisc]+ "'"
		Next
	EndIf
	
	If !EMPTY(cCodProg) 
		cFilterBOS += " AND BOS_CODPRO IN ("+  cCodProg +")" 
	Endif
	
	If !EMPTY(cMatVid)
		cFilterBOS += " AND BOS_VIDA IN ("+ cMatVid +")"
		//cFilterBOS += " .AND. BOS_VIDA IN (" + cMatVid + ") "
	Endif
	//estava com problema pois a variavel/Campo estava retornando como Numerica
/*	If !EMPTY(cCodProg)
		cFilterBOS += " .AND. BOS_CODPRO IN (" + cCodProg + ") "
	Endif
	
	If !EMPTY(cMatVid)
		cFilterBOS += " .AND. BOS_VIDA IN (" + cMatVid + ") "
	Endif*/
	
	If !EMPTY(cCodProg)
		cFilterBOF += " AND BOF_CODPRO IN ("+  cCodProg + ")"
	Endif
	
	If !EMPTY(cRisco)
		cFilterBOF += " AND BOF_RISCO IN ("+ cRisco +")"
	Endif
	
	If !EMPTY(cCodProg)
		cFilterBOE += " AND BOE_CODPRO IN ("+cCodProg +")"
	Endif
	If !EMPTY(cRisco)
		cFilterBOE += " AND BOE_RISCO IN (" + cRisco + ")"
	Endif
	
	HS_BDados("BOF" , @aHeadBOF, @aColsBOF,        , 1   ,        , cFilterBOF,        ,            ,"/"     ,         ,        ,        ,        ,        ,        ,aLegBOF,        ,   .T.   ,           ,         , /*aCpoBOF*/,        ,          , )
	HS_BDados("BOE" , @aHeadBOE, @aColsBOE,        , 1   ,        , cFilterBOE,        ,            ,"/"     ,         ,        ,        ,        ,        ,        ,aLegBOE,        ,   .T.   ,           ,         , aCpoBOE,        ,          , )
	HS_BDados("BOS" , @aHeadBOS, @aColsBOS,        , 1   ,        , cFilterBOS,        ,"BOS_STATUS","/"     ,         ,        ,        ,        ,        ,        ,aLegBOS,        ,   .T.   ,           ,         , /*aCpoBOF*/,        ,          , )
	
	nBOECodPro	:= aScan(aHeadBOE, {|aVet| aVet[2] == "BOE_CODPRO"})
	nBOEItem  	:= aScan(aHeadBOE, {|aVet| aVet[2] == "BOE_ITEM  "})
	
	DEFINE MSDIALOG oDlgAler TITLE OemToAnsi("Recomenda็๕es e Alertas") From 000,000 TO 500, 700	PIXEL of oMainWnd
	
	//@ 015,002 FOLDER oFolder SIZE 465, 350 Pixel OF oDlgAler Prompts "Trat. Medicamentoso", "Nใo Medicamentoso"
	
	@ 200,000 FOLDER oFolder SIZE 460, 125 Pixel OF oDlgAler Prompts "Trat. Medicamentoso", "Nใo Medicamentoso"
	//oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	oFolder:Align := CONTROL_ALIGN_BOTTOM
	
	@ 126,255 SAY oSay PROMPT OemToAnsi(" Trat. Sugerido pelo protocolo") SIZE 120,009 OF oDlgAler PIXEL COLOR CLR_HRED //"Total do Oramento "
	oBOF := MsNewGetDados():New(000, 000, 106, 350,0,,,,,,99999,,,,  oFolder:aDialogs[1], aHeadBOF, aColsBOF)
	oBOE := MsNewGetDados():New(000, 000, 106, 350,0,,,,,,99999,,,,  oFolder:aDialogs[2], aHeadBOE, aColsBOE)
	oBOE:oBrowse:BlDblClick := {|| PProCallCNH(oBOE:aCols[oBOE:nAt,nBOECodPro], oBOE:aCols[oBOE:nAt,nBOEItem]) }
	
	//@ 130,000 FOLDER oFolder2 SIZE 460,125	 OF oDlgAler PROMPTS "Alertas Promo็ใo Sa๚de" PIXEL
	@ 015,002 FOLDER oFolder2 SIZE 465,350	 OF oDlgAler PROMPTS "Alertas Promo็ใo Sa๚de" PIXEL
	//oFolder2:Align := CONTROL_ALIGN_BOTTOM
	oFolder2:Align := CONTROL_ALIGN_ALLCLIENT
	oBOS := MsNewGetDados():New(000, 000, 106, 350,0,,,,,,99999,,,, oFolder2:aDialogs[1], aHeadBOS, aColsBOS)
	
	ACTIVATE MSDIALOG oDlgAler CENTERED
	          
Else
	HELP('PLSFUNP',, 'PLSFUNP',, "Paciente nao possui alertas!", 1, 0)	 //"Nใo foram encontrados novos elegiveis!"	
EndIf


RestArea(aArea)  

Return(nil)

//---------------------------------------------------------------------------
//PProCallCNH - Chamada do Banco de Conhecimento do Tratamento Nใo Med.  		|
//---------------------------------------------------------------------------
Static Function PProCallCNH(cCodPro, cItem)
Local aArea 		:= getArea()
Local aRotBack	:= {}
//Private aRotina := {}

If Type("aRotina") == "U"
	Private aRotina := {}
	//Fun็ใo exige que tenha 4 op็๕es no aRotina ================================
	AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
	AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
	AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
	aAdd( aRotina, { "Conhecimento",		"MsDocument"	, 0, 3, 0, NIL } )
	//============================================================================
	aRotBack := aRotina
Else
	If Len(aRotina) == 0
		//Fun็ใo exige que tenha 4 op็๕es no aRotina ================================
		AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
		AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
		AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
		aAdd( aRotina, { "Conhecimento",		"MsDocument", 0, 3, 0, NIL } )
		//============================================================================
	EndIf
	aRotBack := aRotina 
EndIf

BOE->(DbSetOrder(1))
If BOE->(MsSeek(xFilial("BOE") + cCodPro + cItem))
	cCadastro := "Banco de Conhecimento Tratamento Nใo Med."
	MsDocument( "BOE", BOE->( RecNo() ), 4 )
EndIf	
aRotina := aRotBack
RestArea(aArea)	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSPROALE   บAutor  ณMicrosiga         บ Data ณ  10/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a inclusใo de Alertas na Promo็ใo da Suade         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


FUNCTION PLSPROALE(CCODSIN,CASSUNT,DDATASIN,CHORA,CDESTINO,CMATIVD, CAUTO, CTEXTO, CACAO,CPROGRAM,CTPALERT,CCODLOC)

DEFAULT CAUTO 	:= "0"         
DEFAULT CTEXTO  := ""
DEFAULT CACAO  	:= ""
DEFAULT CCODSIN	:= ""
DEFAULT CASSUNT	:= ""
DEFAULT DDATASIN:= DATE()	
DEFAULT CHORA	:= ""
DEFAULT CDESTINO:= ""
DEFAULT CMATIVD:= ""
DEFAULT cTpAlert := ""
DEFAULT CCODLOC	:=""                      

IF !EMPTY(CCODSIN)
	DBSELECTAREA("BOJ")
	DBSETORDER(1) //BOJ_FILIAL + BOJ_CODSIN
	
	IF BOJ->(MsSeek(xFilial("BOJ")+ CCODSIN))
		IF !EMPTY(CTEXTO)
			CTEXTO := BOJ->BOJ_TEXTO
		ENDIF
		IF !EMPTY(CACAO)
			CACAO := BOJ->BOJ_TXTACAO
		ENDIF
	ENDIF
ENDIF

BOS->(RECLOCK("BOS",.T.))
	BOS->BOS_FILIAL		:=	XFILIAL("BOS")
	BOS->BOS_NROSEQ	:= GETSXENUM('BOS','BOS_NROSEQ',, 1)
	//M->GFU_CDANAM := HS_VSxeNum("GFU", "M->GFU_CDANAM", 1)
	BOS->BOS_RESUMO	:= CASSUNT
	BOS->BOS_DATSIN := DDATASIN
	BOS->BOS_HORAIN	:= CHORA
	BOS->BOS_DESTIN	:= CDESTINO
	BOS->BOS_TEXTO	:= CTEXTO
	BOS->BOS_ACAO   := CACAO
	BOS->BOS_ORIGEM	:= FUNNAME()
	BOS->BOS_DESTIN := CDESTINO
	BOS->BOS_CODSIN	:= CCODSIN
	BOS->BOS_AUTOMA	:= CAUTO
	BOS->BOS_VIDA   := CMATIVD
	BOS->BOS_STATUS := "0"
	BOS->BOS_TPALER := cTpAlert
	BOS->BOS_CODPRO := CPROGRAM
	BOS->BOS_CODLOC := CCODLOC
BOS->(MSUNLOCK())
ConfirmSx8()


RETURN()   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSPROPLA  บAutor  ณMicrosiga           บ Data ณ  10/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Planejamento da Promo็ใo da Saude                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function PLSPROPLA(cNroseq)

Local aRotBack  := aRotina
aRotina := {} 
If  empty(cNroseq)
	MsgInfo("Nใo foi Selecionado Nenhum Paciente da Promo็ใo Da Saude ")
Else          

BOM->(DBSETORDER(2)) //BOJ_FILIAL + BOJ_CODSIN
BOM->(MsSeek(xFilial("BOM")+ cNroseq))
	
PlsPreAg(,,,cNroseq)
Endif 
aRotina  := aRotBack	
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSPROVER   บAutor  ณMicrosiga         บ Data ณ  10/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe Folder do paciente no Prontuario Eletronico          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLSPROVER(aPerPro,oFolder, cVida)
Local lRet 	:= .F.
Local aRetPro := {}           
Local lMVPromo:= SuperGetMV("MV_PROSAUD", NIL, .F.)  // Promo็ใo a Saude           
Default cVida := PLSRTVID(GBH->GBH_CODPAC)
If lMVPromo 
	//cVida :=	PLSRTVID(GBH->GBH_CODPAC)
	aRetPro := PLSELEG(,cVida,"",iIf(valType(aPerPro)=="A",aPerPro,{}))  
	If len(aRetPro)>0
		If MsgYesNO("O Paciente estแ relacionado em um ou mais programas de Saude, deseja verificar?")
			lRet := .T.
		Else			
			lRet := .F.                                                           
		EndIf
	EndIf                             
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPProRetOrder   บAutor  ณMicrosiga           บ Data ณ  11/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function PProRetOrder(cSql, cOrderBy)
Local cQryRet := cSql
Local nAt	:= 0

nAt := At("ORDER BY",cQryRet)
cQryRet := Substr(cSql, 1, nAt - 1)
cOrderBy := Substr(cSql, nAt, Len(cSql))

Return(cQryRet)





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPPROPROIN  บAutor  ณMicrosiga           บ Data ณ  10/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusao no Programa				                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function PPROPROIN(cSeqEleg, cCrm,cvida,cPrograma,oGetBOM, cCodLoc)
Local aRotBack  := aRotina
local cdescrPro		:= "" 
Local aRet			:= {}
Local cStatus		:= 0
Local lStatus		:= .F.
DEFAULT cSeqEleg	:= ""
DEFAULT cCrm		:= ""
DEFAULT cvida		:= ""
DEFAULT cPrograma	:= ""
DEFAULT oGetBOM	    := NIL
DEFAULT cCodLoc		:= ""

aRotina := {} 
 
cdescrPro:=Posicione("BOA",1,xFilial("BOA") +  cPrograma, "BOA_DESPRO")
 
If  Empty(cvida)
	MsgInfo("O Paciente nใo possui Vinculo com o Cadastro de Vidas no Plano de Saude ") 
	aRotina  := aRotBack
	Return()
Endif

If !Empty(cPrograma)  .AND. !Empty(cSeqEleg) 
	dbSelectArea("BOM")
	BOM->(DbSetOrder(2))
	If  BOM->(MsSeek(xFilial("BOM") +cSeqEleg))      
		If BOM->BOM_STATUS == '0'
			lStatus := .T.		
			cStatus := BOM->BOM_STATUS
			cRisco := BOM->BOM_GRARIS
		EndIf	
	EndIf
ElseIf !Empty(cPrograma)
	dbSelectArea("BOM")
	dbSetOrder(1)//BOM_FILIAL, BOM_CODPRO, BOM_VIDA, BOM_STATUS
	If BOM->(dbSeek(xFilial("BOM")+cPrograma+cvida))   
		If BOM->BOM_STATUS == '0' .Or. BOM->BOM_STATUS == '2' 
			lStatus := .T.		
			cStatus := BOM->BOM_STATUS
		EndIf	
	EndIf	
EndIf	

If lStatus
		If MsgYesNO("Deseja Incluir o Paciente no Programa "+cPrograma+" - "+cdescrPro+", continuar?")
			//If Empty(cPrograma) .OR. Empty(cRisco)
			aret      := Fs_ProTela(oGetBOM,lStatus,cPrograma)
			If !Empty(aret[2])  
				cPrograma := aret[1]
				cRisco	  := aret[2]
			EndIf  
			//EndIf
			
			If Empty(cRisco)   
				MsgInfo("Classificacao de risco ou programa nao informados!")
				aRotina  := aRotBack
				Return()
			Endif 
			
			If !Empty(cPrograma) .and. Empty(cRisco) 
				cdescrPro:=Posicione("BOA",1,xFilial("BOA") +  cPrograma, "BOA_DESPRO")
				MsgInfo("Necessario Informar um Risco ao Programa Selecionado "+cPrograma+" - "+cdescrPro)
				aRotina  := aRotBack
			   	Return()
			Endif 
			PPROINCPRO("", cCrm,cPrograma,cvida,cRisco,.T.,BOM->BOM_STATUS, cCodLoc)
			PLSFOREFR(cvida,.T.)      
			
		Else
			aret      := Fs_ProTela(oGetBOM)   //Fs_ProTela(oGetBOM,lStatus,"")  
			cPrograma := aret[1]
			cRisco	  := aret[2]                                          
			
			If Empty(cPrograma)
				aRotina  := aRotBack
				Return()
			Endif 
			
			If !Empty(cPrograma) .and. Empty(cRisco) 
				cdescrPro:=Posicione("BOA",1,xFilial("BOA") +  cPrograma, "BOA_DESPRO")
				MsgInfo("Necessario Informar um Risco ao Programa Selecionado "+cPrograma+" - "+cdescrPro)
				aRotina  := aRotBack
			   	Return()
			Endif 
			PPROINCPRO("", cCrm,cPrograma,cvida,cRisco,.T.,BOM->BOM_STATUS, cCodLoc)
			PLSFOREFR(cvida,.T.) 	
	   	EndIf
	
ElseIf MsgYesNO("Deseja Incluir o Paciente em algum Programa? ", "Incluir no Programa?")
	aret      := Fs_ProTela(oGetBOM)  
	cPrograma := aret[1]
	cRisco	  := aret[2] 
	
	If Empty(cPrograma)
		aRotina  := aRotBack
		Return()
	Endif    
	
	If !Empty(cPrograma) .and. Empty(cRisco) 
		cdescrPro:=Posicione("BOA",1,xFilial("BOA") +  cPrograma, "BOA_DESPRO")
		MsgInfo("Necessario Informar um Risco ao Programa Selecionado "+cPrograma+" - "+cdescrPro)
		aRotina  := aRotBack
	   	Return()
	Endif                
	
	PPROINCPRO("", cCrm,cPrograma,cvida,cRisco,.T.,,cCodLoc)
	PLSFOREFR(cvida,.T.)    
EndIf

aRotina  := aRotBack

If "AMARELO" $ oGetBOM:aCols[oGetBOM:nAt, nGetSTATUS] //ALTA
	oMenuPr06:lActive := .T. //Enable()
	oMenuPr07:lActive := .T. //Enable()	 
Else    
	oMenuPr06:lActive := .F. //Disabled()
	oMenuPr07:lActive := .F. //Disabled()	
EndIf 

return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPHISPERANM  บAutor  ณMicrosiga         บ Data ณ  06/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca historico de respostas para a pergunta		           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PHISPERANM(cCodPer, cRegGer, lGraf)
Local aArea	:= getArea()
Local cSql		:= "" // Variavel que cont้m a query
Local cTipPer	:= "" // Variavel com o tipo da pergunta 
Local cResPer	:= "" // Variavel com o campo de resposta da pergunta de acordo com o tipo
Local aGraph	:= {} // Variavel que contem os dados do grafico 
Local xRet		

Default cRegGer	:= GCY->GCY_REGGER
Default lGraf := .F. // Variavel que indica se serแ retornado o dado para ultima resposta ou todos os os ultimos dados para montagem do grafico
If "_" $ cCodPer
	cCodPer := Alltrim(SubStr(cCodPer, 5, Len(cCodPer)))
EndIf
GCH->(DbSetOrder(1))
If GCH->(MsSeek(xFilial("GCH")+cCodPer))
	cTipPer := GCH->GCH_TIPPER
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', " TIPO PERGUNTA " + cTipPer + " CODPER: " + cCodPer , 0, 0, {})
	If cTipPer == "C" 
		cResPer := "GFK_RESCAR"
	ElseIf cTipPer == "N"
		cResPer := "GFK_RESNUM"
	ElseIf cTipPer == "D"
		cResPer := "GFK_RESDAT"
	ElseIf cTipPer == "M"
		cResPer := "GFK_RESMEM"				
	EndIf 
	If GCH->GCH_GRAFIC <> "1" .AND. lGraf// Pergunta nใo esta atribuida como grafico de evolu็ใo = SIM
		Return()
	EndIf	
EndIf

If !(cTipPer $ "CN") .AND. lGraf
	MsgInfo("Para esta funcionalidade s๓ devem ser utilizadas perguntas do tipo numerico ou caracter!")	
EndIf

cSql := " SELECT GFK.R_E_C_N_O_ RECPER, GFK_RESNUM, GFK_RESCAR, GFK_RESMEM, GFK_RESDAT, GFU_DATCON FROM " + RetSqlName("GFK") + " GFK "    
cSql += " JOIN " + RetSqlName("GFU") + " GFU ON GFU_CDANAM = GFK_CDANAM AND GFU_REGGER = '" + cRegGer + "' "
cSql += " AND GFU_FILIAL = '" + xFilial("GFU") + "' AND GFU.D_E_L_E_T_ <> '*'"   
cSql += " WHERE GFK_CODPER = '" + cCodPer + "' AND GFK_FILIAL = '" + xFilial("GFK") + "' AND GFK.D_E_L_E_T_ <> '*'"
cSql += " ORDER BY GFU_DATCON DESC, GFU_HORCON DESC " 

cSql  := ChangeQuery(cSql)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"QRYPERG",.F.,.T.) 
DbSelectArea("QRYPERG")

If !QRYPERG->(Eof())
	If !lGraf // se for apenas retorno da ultima resposta
		While !QRYPERG->(Eof()) // BUSCA ATษ encontrar a primeira preenchida
			If cTipPer == "M"
				GFK->(DbGoTo(QRYPERG->RECPER))				
				xRet := GFK->GFK_RESMEM
				If !Empty(xRet)
					QRYPERG->(DbCloseArea())					 
					Return(xRet)
				EndIf
			ElseIf cTipPer == "D"
				xRet := &("QRYPERG->" + cResPer)
				If !Empty(xRet)
					QRYPERG->(DbCloseArea())					 
					Return(STOD(xRet))
				EndIf
			ElseIf cTipPer == "N"
				xRet := &("QRYPERG->" + cResPer)
				If !Empty(xRet)
					QRYPERG->(DbCloseArea())					 
					Return(Val(xRet))
				EndIf
			Else                        			 
				xRet := &("QRYPERG->" + cResPer)
				If !Empty(xRet)
					QRYPERG->(DbCloseArea())					 
					Return(xRet)
				EndIf
			EndIf
			QRYPERG->(DbSkip())
		EndDo		
	Else
		While !QRYPERG->(Eof())
			If cTipPer == "C"
				AADD(aGraph, {QRYPERG->GFU_DATCON,Val(&("QRYPERG->" + cResPer))})
			Else
				AADD(aGraph, {QRYPERG->GFU_DATCON,Val(&("QRYPERG->" + cResPer))})
			Endif 		
			QRYPERG->(DbSkip())
		EndDo
		If Len(aGraph) > 0
			PProMntGraf( ,aGraph, "4", Alltrim(GCH->GCH_DESPER))
		EndIf
	EndIf
EndIf
If cTipPer == "C"
	xRet:=space(TamSx3("GFK_RESCAR")[1])
ElseIf cTipPer == "M"
	xRet:=space(TamSx3("GFK_RESMEM")[1])
ElseIf cTipPer == "D"
	xRet:= Ctod("")
ElseIf cTipPer == "N"
	xRet:= 0
Endif

QRYPERG->(DbCloseArea())
RestArea(aArea)
Return(xRet)
//---------------------------------------------------------------------------
//PProCriaTrb - Cria tabela temporaria para inclusใo dos registros encontrados|
// na query de elegibilidade														 |
//---------------------------------------------------------------------------
	/*aCpo := {}
	AADD(aCpo,{"FILIAL"   		,"C",02,0})
	AADD(aCpo,{"RA_MAT"   		,"C",06,0})
	AADD(aCpo,{"VALOR"   		,"N",15,2})
	*/
Static Function PProCriaTrb(aStruct, cKey)
Local cTRB 	:= ""
Local cIndex 	:= ""

//==============================================================================================================
//Montagem da Estrutura da Tabela Temporaria TRB
//==============================================================================================================
Default cKey :=  "BOA_CODPRO+BTS_MATVID+BOB_GRAU"  
If Select("TRBTMP")>0
	DbSelectArea("TRBTMP")
	TRB->(DbCloseArea())
Endif

cTRB:= FWTemporaryTable():New( "TRBTMP" )
cTRB:SetFields(aStruct)
cTRB:AddIndex("01", {cKey} )
cTRB:Create()
Return()
//==========================================================
//Gravacao na Tabela Temporaria
//==========================================================
Static Function PProGravTrb(cAliasOri, aStruct)
Local nI	:= 0
Begin Transaction
	RecLock("TRBTMP",.T.)
	For nI := 1 To Len(aStruct)
		&("TRBTMP->" + aStruct[nI,1]) := &(cAliasOri + "->" + aStruct[nI,1])		
	Next nI
	TRBTMP->(MsUnlock())
End Transaction
Return()

//==========================================================
//Separa็ใo da string das querys em vetor divido por UNION  |
//==========================================================
Static Function PProSepQry(cStr)
Local aRet 	:= {}
Local cQryAdd	:= ""
Local nAt		:= 0


cStr := StrTran(Upper(cStr), "UNION ALL", "UNION ") // retira o UNION ALL para um unico tratamento

While (nAt := At("UNION",cStr)) > 0 // enquanto tiver UNION separa	
	cQryAdd := Substr(cStr, 1, nAt - 1) // Concatena at้ antes do union
	cStr := Substr(cStr, nAt+5, Len(cStr)) //Retira a primeira string e o UNION pra continuar o While
	AADD(aRet, cQryAdd)
EndDo
If !Empty(cStr) 
	AADD(aRet, cStr)
EndIf
Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณPlsBcoConณ Autor ณ                        ณ Data ณ  23/11/12 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Banco de conhecimento dos itens                            ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณSintaxe   ณ 				                                               ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Uso      ณ Advanced Protheus                                          ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Alteracoes desde sua construcao inicial.                              ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PLSPROAUT(cMatvid, cRegPac)                 

Local aArea		:= GetArea()
//Local aAreaBEA	:= BEA->(GetArea())
//Local aRotBack  := aRotina
//Local cQuery	:= ""
//Local cIndex	:= ""
//Local dDatIni	:= (dDataBase - 182) // 6 meses              

Default cRegPac	:= ""
 
If !Empty(cRegPac)
	DbSelectArea("GD4")
	DbSetOrder(2) //Gd4_FILIAL + GD4_REGGER
	DbSeek(xFilial("GD4") + cRegPac+"1" )
	
	DbSelectArea("BA1")
	BA1->(DbSetOrder(2))
	If !BA1->(MsSeek(xFilial("BA1")+GD4->GD4_MATRIC))  
		BA1->(DbSetOrder(7))
		BA1->(MsSeek(xFilial("BA1")+cMatvid))
	EndIf 
Else
	BA1->(DbSetOrder(7))
	BA1->(MsSeek(xFilial("BA1")+cMatvid))
EndIf
	
PLHISMOV(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))                                     
/*aRotina := {{"Conhecimento",'MsDocument',0,3}} //"Conhecimento"

DbSelectArea("BE2") 

cIndex := CriaTrab(NIL,.F.)
cQuery := "BE2_FILIAL == '" + xFilial("BE2") + "' "
cQuery += " .And. BE2_MATVID == '" + cMatvid + "'" 
cQuery += " .And. DTOS(BE2_DATPRO) >= '" + DTOS(dDatIni) + "'"
cQuery += " .And. BE2_TPPROC == '0'"

IndRegua("BE2",cIndex,BE2->(IndexKey()),,cQuery)

If BE2->(!Eof())
	MsgRun("Buscando movimenta็๕es...",, { || MaWndBrowse(0,0,300,600,"Exames / Procedimentos","BE2",,aRotina,,,,.T.,,,,,,.F.)}) 
	//MaWndBrowse(0,0,300,600,"Retorno de Doctos. de Saida","BE2",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
Else
	MsgInfo("Paciente nใo possui movimenta็๕es!")
EndIf

RetIndex( "BE2" )    
dbClearFilter()
FErase( cIndex+OrdBagExt() )

aRotina := aRotBack

dbSelectArea("BE2")
dbSetOrder(1)

BEA->( RestArea(aAreaBEA) )
*/
RestArea(aArea)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSPESCID บAutor  ณMicrosiga          บ Data ณ  12/13/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela de pesquisa do CID.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PLSPESCID()  
LOCAL cTipoPes   	:= ""
LOCAL nLin		   	:= 1
Local nOpca	        := 0  
LOCAL cChave     	:= Space(40)
LOCAL oDlgPesCid    := NIL
LOCAL oTipoPes		:= NIL
LOCAL oSayPro       := NIL
LOCAL oBrowCID		:= NIL
LOCAL oGetChave		:= NIL
LOCAL oChkChk		:= NIL
LOCAL aBrowCid   	:= { {"",""} } 
LOCAL bOK        	:= { || If(!Empty(cChave),(nLin := oBrowCid:nAt,nOpca := 1,lOk:=.T.,oDlgPesCid:End()),Help("",1,"PLSFUNP")) }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPesCid:End() }
LOCAL aTipoPes   	:= {}
LOCAL lChkChk    	:= .F.
LOCAL lRet		 	:= .F.
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL dDatAnalise	:= dDataBase
LOCAL dDatPro		:= dDataBase
LOCAL lReembolso	:= .F.     
LOCAL aItensPac     := {}
LOCAL bRefresh   	:= { || If(!Empty(cChave),PLSQRYCID(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowCid,oBrowCid),.T.), If( Empty(aBrowCid[1,1]) .And. !Empty(cChave),.F.,.T. )  }
PRIVATE aOpcoes   	:= {}
PRIVATE cCadastro 	:= "" 

aTipoPes := {"1- Descri็ใo do CID","2-Codigo do CID"}
	   		aadd(aOpcoes,{"BA9_DOENCA"})
		 	aadd(aOpcoes,{"BA9_CODDOE"})            

DEFINE MSDIALOG oDlgPesCid TITLE "Pesquisa CID" FROM 008.2,000 TO 030,100 OF GetWndDefault()

oGetChave := TGet():New(020,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesCid,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

oBrowCID := TcBrowse():New( 043, 008, 378, 090,,,, oDlgPesCid,,,,,,,,,,,, .F.,, .T.,, .F., )
	
oBrowCID:AddColumn(TcColumn():New("C๓digo",nil,nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowCID:ACOLUMNS[1]:BDATA := { || aBrowCid[oBrowCID:nAt,1] }
oBrowCID:AddColumn(TcColumn():New("Descricao",nil,nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowCID:ACOLUMNS[2]:BDATA := { || aBrowCid[oBrowCID:nAt,2] }
	 
@ 020,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesCid PIXEL COLOR CLR_HBLUE
@ 020,315 CHECKBOX oChkChk   Var lChkChk PROMPT "Pesquisar Palavra Chave" PIXEL SIZE 080, 010 OF oDlgPesCid   

oBrowCID:SetArray(aBrowCid)
oBrowCID:BLDBLCLICK := bOK
oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}
	
ACTIVATE MSDIALOG oDlgPesCid ON INIT Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlgPesCid,bOK,bCanc,.F.,) })

If nOpca == K_OK
	If !Empty( aBrowCid[nLin,1] ) 
		BA9->(dbSetOrder(1))
		BA9->(dbSeek(xFilial("BA9")+aBrowCid[nLin,1]))
		//M->BE1_CID := aBrowCid[nLin,1]
	EndIf	
EndIf

Return(.T.)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSQRYCID บAutor  ณMicrosiga          บ Data ณ  12/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Query para retornar a pesquisa do CID.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PLSQRYCID(cChave,cTipoPes,lChkChk,aBrowCid,oBrowCid)

LOCAL aArea   	:= GetArea()
LOCAL cSQL      := ""                          

If '"' $ cChave .Or. "'" $ cChave

   Aviso( "Caracter Invalido",;
          "Existem caracteres invalidos em sua pesquisa.",;
          { "Ok" }, 2 ) 	                                                                    

   Return(.F.)

EndIf   

aBrowCid := {}

cSQL := "SELECT BA9_CODDOE, BA9_DOENCA, BA9_ABREVI "
cSQL += "  FROM "+RetSQLNAME("BA9")
cSQL += " WHERE BA9_FILIAL = '"+xFilial("BA9")+"' AND " 
	
If lChkChk
   cSQL += aOpcoes[Val(cTipoPes),1]+" LIKE '%"+AllTrim(cChave)+"%' "
Else
   cSQL += aOpcoes[Val(cTipoPes),1]+" LIKE '"+AllTrim(cChave)+"%' "
Endif   
	          
cSQL += " AND D_E_L_E_T_ = ' ' "

cSQL += "ORDER BY BA9_FILIAL,"+aOpcoes[Val(cTipoPes),1]

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes",.F.,.T.)

TrbPes->( DbGoTop() )
While !TrbPes->( Eof() )

	TrbPes->( AaDd( aBrowCid,{ BA9_CODDOE,BA9_DOENCA} ) )
	TrbPes->( DbSkip() )	
EndDo

TrbPes->( DbCloseArea() )

RestArea(aArea)

If Len(aBrowCid) == 0
   aBrowCid := { {"",""} }
EndIf       

oBrowCid:SetArray(aBrowCid)
oBrowCid:Refresh()
oBrowCid:SetFocus()                

Return(.T.)                     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSPESPRO บAutor  ณMicrosiga          บ Data ณ  17/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela de pesquisa do Prodecimento.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PLSPESPRO()  
LOCAL cTipoPes   	:= ""
LOCAL nLin		   	:= 1
Local nOpca	        := 0  
LOCAL cChave     	:= Space(40)
LOCAL oDlgPesPro    := NIL
LOCAL oTipoPes		:= NIL
LOCAL oSayPro       := NIL
LOCAL oBrowPro		:= NIL
LOCAL oGetChave		:= NIL
LOCAL oChkChk		:= NIL
LOCAL aBrowPro   	:= { {"","",""} } 
LOCAL bOK        	:= { || If(!Empty(cChave),(nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End()),Help("",1,"PLSFUNP")) }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
LOCAL aTipoPes   	:= {}
LOCAL lChkChk    	:= .F.
LOCAL lRet		 	:= .F.
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL dDatAnalise	:= dDataBase
LOCAL dDatPro		:= dDataBase
LOCAL lReembolso	:= .F.     
LOCAL aItensPac     := {}
LOCAL bRefresh   	:= { || If(!Empty(cChave),PLSQRYPro(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowPro,oBrowPro),.T.), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
//Local nPTab    		:= Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_CODTAB"})
//Local nPProc   		:= Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_PROCED"}) 

PRIVATE aOpcoes   	:= {}
PRIVATE cCadastro 	:= "" 

aTipoPes := {"1- Descri็ใo do Procedimento","2-Codigo do Procedimento"}
	   		aadd(aOpcoes,{"BR8_DESCRI"})
		 	aadd(aOpcoes,{"BR8_CODPSA"})            

DEFINE MSDIALOG oDlgPesPro TITLE "Pesquisa Procedimento" FROM 008.2,000 TO 030,100 OF GetWndDefault()

oGetChave := TGet():New(040,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

oBrowPro := TcBrowse():New( 063, 008, 378, 090,,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )
	
oBrowPro:AddColumn(TcColumn():New("Tabela",nil,nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[1]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }    
oBrowPro:AddColumn(TcColumn():New("C๓digo",nil,nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }         
oBrowPro:AddColumn(TcColumn():New("Descricao",nil,nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,3] }
	 
@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
@ 040,315 CHECKBOX oChkChk   Var lChkChk PROMPT "Pesquisar Palavra Chave" PIXEL SIZE 080, 010 OF oDlgPesPro   

oBrowPro:SetArray(aBrowPro)
oBrowPro:BLDBLCLICK := bOK
oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}
	
ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,) })

If nOpca == K_OK
	If !Empty( aBrowPro[nLin,1] ) 
		BR8->(dbSetOrder(1))
		BR8->(dbSeek(xFilial("BR8")+aBrowPro[nLin,1]+aBrowPro[nLin,2]))
		lRet:=.T.
		//oBOQ:aCols[oBOQ:nAt][nPTab]  := aBrowPro[nLin,1]
		//oBOQ:aCols[oBOQ:nAt][nPProc] := aBrowPro[nLin,2]
	EndIf	
Else             
	If Type("M->BOQ_CODTAB") <> "U"
			M->BOQ_CODTAB := SPACE(Len(M->BOQ_CODTAB))
	Endif
	lRet:=.F.
EndIf
Return(lRet)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSQRYPRO บAutor  ณMicrosiga          บ Data ณ  17/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Query para retornar a pesquisa do Procedimento.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PLSQRYPRO(cChave,cTipoPes,lChkChk,aBrowPro,oBrowPro)

LOCAL aArea   	:= GetArea()
LOCAL cSQL      := ""                          

If '"' $ cChave .Or. "'" $ cChave

   Aviso( "Caracter Invalido",;
          "Existem caracteres invalidos em sua pesquisa.",;
          { "Ok" }, 2 ) 	                                                                    

   Return(.F.)

EndIf   

aBrowPro := {}

cSQL := "SELECT BR8_CODPAD, BR8_CODPSA, BR8_DESCRI "
cSQL += "  FROM "+RetSQLNAME("BR8")
cSQL += " WHERE BR8_FILIAL = '"+xFilial("BR8")+"' AND " 
	
If lChkChk
   cSQL += aOpcoes[Val(cTipoPes),1]+" LIKE '%"+AllTrim(cChave)+"%' "
Else
   cSQL += aOpcoes[Val(cTipoPes),1]+" LIKE '"+AllTrim(cChave)+"%' "
Endif   
	          
cSQL += " AND D_E_L_E_T_ = ' ' "

cSQL += "ORDER BY BR8_FILIAL,"+aOpcoes[Val(cTipoPes),1]

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPro",.F.,.T.)

TrbPro->( DbGoTop() )
While !TrbPro->( Eof() )

	TrbPro->( AaDd( aBrowPro,{ BR8_CODPAD,BR8_CODPSA,BR8_DESCRI} ) )
	TrbPro->( DbSkip() )	
EndDo

TrbPro->( DbCloseArea() )

RestArea(aArea)

If Len(aBrowPro) == 0
   aBrowPro := { {"","",""} }
EndIf       

oBrowPro:SetArray(aBrowPro)
oBrowPro:Refresh()
oBrowPro:SetFocus()                

Return(.T.)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFs_ProTela   บAutor  ณMicrosiga           บ Data ณ  12/26/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Fs_ProTela(oGetBOM,lStatus,cCdProgram)	
Local aArea    	:= 	GetArea()
Local aHBOA    	:= 	{}
Local aCBOA    	:= 	{}
Local nOpcA    	:= 	0
Local oBOA
Local nFor     	:= 	0
Local nUBOA   	:= 	0
Local nUBOB    	:= 	0
Local cSql     	:= 	""
Local cCond		:=	""
//Local cCdProgram:=	""
lOCAL cLstEsp	:=	""
LOCAL nI		:=	0
LOCAL lFilVir	:=	.T.
LOCAL cRisco	:=	""
Private oBOB
Private aHBOB   := {}
Private aCBOB   := {} 
Default cCdProgram := ""

    For ni := 1 to len(oGetBOM:acols) 
    	If !Empty(cCdProgram).And. oGetBOM:acols[ni][2]  == cCdProgram
			cLstEsp +=  oGetBOM:acols[ni][2]+"/"  
		ElseIf Empty(cCdProgram)
			cLstEsp +=  oGetBOM:acols[ni][2]+"/"  	
		EndIf	
    Next NI

	cLstEsp := IIF(lFilVir, "'"+StrTran(SUBSTR(cLstEsp,1,len(cLstEsp)-1),"/","','")+"","'") 

    If lStatus
	    cCond:=" BOA_ATIVO = '1' AND BOA_CODPRO IN ("+cLstEsp+"')"
    Else
	    cCond:=" BOA_ATIVO = '1' AND BOA_CODPRO NOT IN ("+cLstEsp+"')"
    EndIf
    
	nUBOA := (HS_BDados("BOA", @aHBOA, @aCBOA,, 1,, cCond,,,,,,, "BOA_IDMARK", "'LBNO'")) 
	nBOAIDMARK := aScan(aHBOA, {| aVet | aVet[2] == "BOA_IDMARK"})
	nBOACODPRO := aScan(aHBOA, {| aVet | aVet[2] == "BOA_CODPRO"})
	
If nUBOA==0
	Return({"",""}) 
Endif

cCond2:=" BOB_CODPRO NOT IN ("+cLstEsp+"')"

nUBOB := (HS_BDados("BOB", @aHBOB, @aCBOB,, 1,, cCond2,,,,,,, "BOB_IDMARK", "'LBNO'"))
nBOBIDMARK 	:= aScan(aHBOB, {| aVet | aVet[2] == "BOB_IDMARK"})
nBOBCODPRO 	:= aScan(aHBOB, {| aVet | aVet[2] == "BOB_CODPRO"})
nBOBGRAU	:= aScan(aHBOB, {| aVet | aVet[2] == "BOB_GRAU  "})


aSize    := MsAdvSize(.T.)
aObjects := {}

aAdd( aObjects, { 100, 030, .T., .T.} )
aAdd( aObjects, { 100, 070, .T., .T.} )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )
	
nOpcA := 0
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Programas da Promo็ใo") From aSize[7], 000 To aSize[6]/2, aSize[5]/2	PIXEL Of oMainWnd

oBOA := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4],,,,,,,,,,,, aHBOA, aCBOA)
oBOA:oBrowse:Align :=  CONTROL_ALIGN_TOP
oBOA:oBrowse:BlDblClick := {|| FS_DblClik(oBOA)}
oBOA:oBrowse:bChange       := {|| FS_AtTela(oBOA:aCols[oBOA:nAt, nBOACODPRO])}


oBOB := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3]/2, aPObjs[2, 4]/2,,,,,,,,,,,, aHBOB, aCBOB)
oBOB:oBrowse:Align := CONTROL_ALIGN_BOTTOM
oBOB:oBrowse:BlDblClick := {|| FS_DblClik(oBOB)}

	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1,  oDlg:End()}, ;
{|| nOpcA := 0, oDlg:End()})
If nOpcA == 1
	
	For nFor := 1 To Len(oBOA:aCols)
		If oBOA:aCols[nFor, nBOAIDMARK] == "LBTIK"
			cCdProgram := oBOA:aCols[nFor, nBOACODPRO]
			Exit
		EndIf
	Next
	For nFor := 1 To Len(oBOB:aCols)
		If oBOB:aCols[nFor, nBOBIDMARK] == "LBTIK"
			cRisco := oBOB:aCols[nFor, nBOBGRAU]
			Exit
		EndIf
	Next
	
EndIf

RestArea(aArea)

Return({cCdProgram,cRisco})    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DblClik บAutor  ณ                    บ Data ณ 20/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para marcar e desmarcar o item.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DblClik(oBOA)
	Local nFor := 0
	// Limpa todos os campos menos o que estแ posicionado
 For nFor := 1 To Len(oBOA:aCols)
	 If oBOA:oBrowse:nAt != nFor
	    oBOA:aCols[nFor, nBOAIDMARK] := "LBNO" 
  EndIf 
 Next 
 oBOA:aCols[oBOA:oBrowse:nAt, nBOAIDMARK] := IIf(oBOA:aCols[oBOA:oBrowse:nAt, nBOAIDMARK] == "LBTIK", "LBNO", "LBTIK")
 oBOA:oBrowse:Refresh()
Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_AtTela บ Autor ณ 				     บ Data ณ 27/12/12    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza a MSNewGetDados com os dados da bom               บฑฑ
ฑฑบ          ณ          de acordo com o 				 escolhido        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 					                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 

Static Function FS_AtTela(cProgr)
Local cCond2	:= ""  
Default cProgr:=""	
aCBOB := {}

cCond2:=" BOB_CODPRO = "+cProgr+""
    
HS_BDados("BOB", @aHBOB, @aCBOB,, 1,, cCond2,,,,,,, "BOB_IDMARK", "'LBNO'")

oBOB:SetArray(aCBOB)
oBOB:oBrowse:Refresh()  

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSSINMED บAutor  ณMicrosiga           บ Data ณ  10/01/13  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ao para apresentar / alertar ao medico sobre os seus   บฑฑ
ฑฑบ          ณ pacientes que foram internados.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PLSSINMED()  
Local aArea      := GetArea()
Local cFilterBOS := ""
Local nPVida     := 0
Local nPData     := 0
Local dData      := dDataBase - 7
Local nB	     := 0  
Local aAux       := {}
Local aLegBOS    := {}
Local aHeader    := {}
Local aCols      := {}
Local oBOS
Local oDlgAler
Local cUserAut   := aCodUsr[2]
              


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณa Variavel aRotina foi declarada dentro desta fun็ao      ณ
//ณpara que seja possivel a visualiza็ใo da tabela BOS       ณ
//ณevitando o seguinte erro:                                 ณ
//ณarray out of bounds [2] of [0] on MSMGET:NEW(MSMGETPR.PRW)ณ
//ณquando chama a fun็ao AxVisual no trecho do codigo		 ณ
//ณoBOS:oBrowse:BlDblClick ...								 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ*/

Private aRotina := {{ "Pesquisar",'AxPesqui'  	, 0 , K_Pesquisar  	, 0 , .F.},; //"Pesquisar"
                   	{ "Visualizar",'AxVisual'	, 0 , K_Visualizar 	, 0 , Nil},; //"Visualizar"
                   	{ "Incluir",'AxInclui'		, 0 , K_Incluir    	, 0 , Nil},; //"Incluir"
                   	{ "Excluir",'AxDeleta'		, 0 , K_Excluir    	, 0 , Nil},; //"Excluir"
                   	{ "Alterar",'AxAltera'		, 0 , K_Alterar    	, 0 , Nil}}  //"Alterar"      

dbSelectArea("BOM")
dbSetOrder(3)

INCLUI := .F.

cFilterBOS := "BOS_FILIAL == '" + xFilial("BOS") + "' "
cFilterBOS += " .AND. BOS_STATUS == '0' "
cFilterBOS += " .AND. BOS_TPALER == '0' " // INTERNAวAO
cFilterBOS += " .AND. BOS_DATSIN >= '" + DtoS(dData) + "'"

HS_BDados("BOS" ,@aHeader, @aCols,         , 1   ,        , cFilterBOS,   ,"BOS_STATUS","/" ,         ,        ,        ,        ,        ,        ,aLegBOS,      ,   .T.   ,           ,         ,         ,      ,          ,"BOS_DATSIN DESC",      ,         ,           ,         )

dbSelectArea("BOM")
dbSetOrder(3) //BOM_FILIAL, BOM_VIDA, BOM_STATUS                          

nPVida   := Ascan(aHeader,{|x| Alltrim(x[2])=="BOS_VIDA"})
nPData   := Ascan(aHeader,{|x| Alltrim(x[2])=="BOS_DATSIN"})

If nPVida > 0
	For nB := 1 To Len(aCols)
		If BOM->(dbSeek(xFilial("BOM")+aCols[nB,nPVida]+"1"))		
			If BOM->BOM_MEDRSP == cUserAut 
				aadd(aAux,aCols[nB])
			EndIf
		EndIf
	Next nB	
	//oBOS:SetArray(aAux)
	//oBOS:oBrowse:Refresh(aAux)
EndIf

If Len(aAux) == 0 // Se nao possuir registros nao exibe janela
	Return()
EndIf

dbSelectArea("BOS")
dbSetOrder(3) //BOS_FILIAL, BOS_VIDA, BOS_CODPRO
	
DEFINE MSDIALOG oDlgAler TITLE OemToAnsi("Recomenda็๕es e Alertas") From 000,000 TO 500, 700	PIXEL of oMainWnd   
	
@ 015,002 FOLDER oFolder2 SIZE 465,350	 OF oDlgAler PROMPTS "Alertas Promo็ใo Sa๚de" PIXEL
oFolder2:Align := CONTROL_ALIGN_ALLCLIENT
oBOS := MsNewGetDados():New(000, 000, 235, 350,0,,,,,,99999,,,, oFolder2:aDialogs[1], aHeader, aAux)   
oBOS:oBrowse:BlDblClick := { || BOS->(DbGoTo(oBOS:aCols[oBOS:oBrowse:nAt, 6])), BOS->(AxVisual("BOS",BOS->(Recno()),K_Visualizar)) }

ACTIVATE MSDIALOG oDlgAler CENTERED  


RestArea(aArea)  

Return(nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPPROEXSQL   บAutor  ณMicrosiga        บ Data ณ  01/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa  query de elegibilidade na Hora da Busca Elegivel  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGAMENTO SAUDE                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PPROEXSQL(cProgram, cIteRegra,nQtdPont)
Local aArea     	:= getArea()
Local nI 			:=	0
Local nL 			:=	0
Local cSql			:= ""
Local cSelect   	:= ""
Local cFrom 		:= ""
Local cWhere		:= ""
Local aCondic		:= {}
Local cTipEleg  	:= ""
Local cWhrSHav  	:= ""
Local cQueryFull	:= ""
Local cGroup		:= ""
Local cSintax		:= ""
Local cTipAtu		:= ""
Local lPontu 		:= .F.
Local lCampo 		:= .F.
Local lProc 		:= .F.
//Private nQtdPont	:= 0

cSql := " SELECT BOP_TIPELE, BOP_STXCND "
cSql += " FROM " + RetSqlName("BOP") + " BOP " 
cSql += " WHERE BOP_ITEREG = '" + cIteRegra + " ' AND D_E_L_E_T_ = ' ' "
cSql += " ORDER BY BOP_TIPELE " 

cSql  := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"QRYREGR",.F.,.T.) 

DbSelectArea("QRYREGR")

While !QRYREGR->(Eof())
	If QRYREGR->BOP_TIPELE == '1'
		lCampo := .T.

	ElseIf QRYREGR->BOP_TIPELE == '2'
		lProc := .T.

	ElseIf QRYREGR->BOP_TIPELE == '3'
		lPontu := .T.
	EndIf
	
	QRYREGR->(dbSkip())
EndDo

QRYREGR->(dbGoTop()) 

While !QRYREGR->(Eof()) 
	If "HAVING" $ Alltrim(QRYREGR->BOP_STXCND)
		AADD(aCondic, {QRYREGR->BOP_STXCND, QRYREGR->BOP_TIPELE}) 
		nQtdPont ++
	Else       
		If QRYREGR->BOP_TIPELE $ '04'
			If !Empty(cSintax)
				cWhrSHav += " OR ( "
				cWhrSHav += Alltrim(QRYREGR->BOP_STXCND) + " ) "
			Else 
				If Empty(cWhrSHav) 
					cWhrSHav := "(("
				Else	
			    	cWhrSHav += " AND (("		
			    EndIf
				cWhrSHav += Alltrim(QRYREGR->BOP_STXCND) + " ) "		
			EndIf

		ElseIf 	QRYREGR->BOP_TIPELE <> cTipAtu .AND. !Empty(cSintax)
			cWhrSHav += ")"
			cWhrSHav += IIf(!Empty(cWhrSHav), " AND ", "")			                  
			
			If 	lPontu .And. QRYREGR->BOP_TIPELE $ '12'
				cWhrSHav += "("
			EndIf					
			
			cWhrSHav += Alltrim(QRYREGR->BOP_STXCND) 
		Else
			cWhrSHav += IIf(!Empty(cWhrSHav), " AND ", "")		
			
			If 	lPontu .And. QRYREGR->BOP_TIPELE $ '12'
				cWhrSHav += "("
			EndIf	
			
			cWhrSHav += Alltrim(QRYREGR->BOP_STXCND) 		
		EndIf    
		
		If QRYREGR->BOP_TIPELE $ '04' .AND. (IIf(Empty(cTipAtu), .T.,cTipAtu == QRYREGR->BOP_TIPELE))
			cSintax := Alltrim(QRYREGR->BOP_STXCND)		
		ElseIF QRYREGR->BOP_TIPELE $ '04'
			cSintax := ")"
		Else 			
  			cSintax := " "
		EndIf
		
		If !(QRYREGR->BOP_TIPELE $ cTipEleg)
			cTipEleg += QRYREGR->BOP_TIPELE
		EndIf
	EndIf	           

	cTipAtu := QRYREGR->BOP_TIPELE
	QRYREGR->(DbSkip())	

	If QRYREGR->(Eof()) .And. cTipAtu $ '04'  //3'
		cWhrSHav += ")"	     
	ElseIf QRYREGR->(Eof()) .And. cTipAtu $ '3' .And. !lCampo .And. !lProc .And. nQtdPont == 1 .And. !Empty(cWhrSHav)
		cWhrSHav += ")"		
	ElseIf (cTipAtu $ '1' .And. lPontu) .Or.  (cTipAtu $ '2' .And. lPontu)
		cWhrSHav += ")"		
	EndIf
EndDo

If !Empty(cWhrSHav) .and. !Empty(cTipEleg)
	AADD(aCondic, {cWhrSHav, cTipEleg})	
EndIf    

QRYREGR->(DbCloseArea())

For nL := 1 To Len(aCondic)
	cSelect 	:= ""
	cFrom 		:= ""
	cWhere		:= ""
	cGroup		:= ""

	If len(aCondic[nL,2]) > 0
		PProMntSelect(@cSelect, aCondic[nL,2], @cGroup)
		PProMntJoin(@cFrom, aCondic[nL,2])
		PProMntWhere(@cWhere ,aCondic[nL,1], aCondic[nL,2],cProgram)
		
		If !Empty(cSelect) .AND. !Empty(cFrom) .AND. !Empty(cWhere)
			If !Empty(cQueryFull)
				cQueryFull += Chr(10)+Chr(13)+ " UNION ALL " + Chr(10)+Chr(13)
			EndIf
			cQueryFull += cSelect + Chr(10)+Chr(13)
			cQueryFull += cFrom + Chr(10)+Chr(13)
			cQueryFull += cWhere + Chr(10)+Chr(13)
		EndIf
		If !Empty(cGroup) .And. !("GROUP" $ cQueryFull)
			cQueryFull += Chr(10)+Chr(13) + " GROUP BY " + cGroup
		EndIf
	EndIf
Next nL

If !Empty(cQueryFull) // Grava a Query
	cQueryFull += Chr(10)+Chr(13) + " ORDER BY BTS_MATVID "
EndIf

cQueryFull := PProExMacro(cQueryFull) // Executa os macros da query

RestArea(aArea)
Return(cQueryFull)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSFUNP   บAutor  ณMicrosiga           บ Data ณ  02/15/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ao para gatilhar valor no campo  M->GCH_RELRES quando  บฑฑ
ฑฑบ          ณ o campo GCH_ULTPER for igual a "1".                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function VdIniPer()
Local lRet := .T.

If M->GCH_ULTPER == "1"
	M->GCH_RELRES := 'PHSPERANM("'+M->GCH_CODPER+'")'
Else
	M->GCH_RELRES := ""
EndIf	

Return lRet  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_ListPro   บAutor  ณTOTVS          บ Data ณ  20/03/13    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para seleceionar as regras de elegibilidade.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SAUDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function FS_ListPro(lStatus)
Local aArea    	:= GetArea()
Local aHBOC    	:= {}
Local aCBOC    	:= {}
Local nOpcA    	:= 0
Local oBOC
Local nFor     	:= 0
Local nUBOC   	:= 0
Local cSql     	:= ""
Local cCond		:= ""
Local cCdProgram:= ""
lOCAL cLstEsp	:= ""
LOCAL nI		:= 0
LOCAL lFilVir	:= .T.
LOCAL cRisco	:= ""   
Private aRegra	:= {}   

cCond:=" BOC_CODPRO == ("+BOA->BOA_CODPRO+")"
    
nUBOC := (HS_BDados("BOC", @aHBOC, @aCBOC,, 1,, cCond,,,,,,, "BOC_IDMARK", "'LBNO'")) 
nBOCIDMARK := aScan(aHBOC, {| X | X[2] == "BOC_IDMARK"})
nBOCRegra  := aScan(aHBOC, {| X | AllTrim(X[2]) == "BOC_REGRA"})
nBOCRisco  := aScan(aHBOC, {| X | AllTrim(X[2]) == "BOC_RISCO"})
	
If nUBOC==0
	Return({"",""}) 
Endif

aSize    := MsAdvSize(.T.)
aObjects := {}

aAdd( aObjects, { 100, 030, .T., .T.} )
aAdd( aObjects, { 100, 070, .T., .T.} )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )
	
nOpcA := 0
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Regras de Elegibilidade") From aSize[7], 000 To aSize[3]/2.2, aSize[5]/2	PIXEL Of oMainWnd

oBOC := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4],,,,,,,,,,,, aHBOC, aCBOC)
oBOC:oBrowse:Align :=  CONTROL_ALIGN_TOP
oBOC:oBrowse:BlDblClick := {|| FS_BOClik(oBOC)}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1,  oDlg:End()}, {|| nOpcA := 0, oDlg:End()}) 

If nOpcA == 1
	
	For nFor := 1 To Len(oBOC:aCols)
		If oBOC:aCols[nFor, nBOCIDMARK] == "LBTIK"
			AADD(aRegra,{oBOC:aCols[nFor, nBOCRegra], oBOC:aCols[nFor, nBOCRisco] })
		EndIf
	Next
	aRegra := aSort(aRegra,,, {|x,y| x[2] > y[2] })  // Organiza por Risco maior para o menor
EndIf

RestArea(aArea)

Return(aRegra)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ALTRIS  บAutor  ณ TOTVS              บ Data ณ 03/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValida a altera็ao da Classifica็ใo de Risco.               บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_ALTRIS(nLin,nPosRis,nPosPro,nPosVida,nPosEle)
Local cCodPro := oGetBOM:aCols[nLin][nPosPro]
Local cVida   := oGetBOM:aCols[nLin][nPosVida]
Local cRisco  := oGetBOM:aCols[nLin][nPosRis]
Local cSeqEle := oGetBOM:aCols[nLin][nPosEle]
Local cRiscoI	:=""
Local cRiscoF	:=""

dbSelectArea("BOM")
BOM->(DbSetOrder(1))

If BOM->(MsSeek(xFilial("BOM") + cCodPro + cVida))
	If !(BOM->BOM_STATUS == '1' .Or. BOM->BOM_STATUS == '3') //0=Elegivel;1=Inscrito;2=Finalizado;3=Pendencias;4=Bloqueado
		MsgInfo("A altera็ใo s๓ ้ permitida para pacientes Inscritos ou com Pend๊ncias!")   
		M->BOM_GRARIS := cRisco
	ElseIf MsgYesNO("Confirma a Altera็ใo da Classifica็ใo de Risco do Programa? ", "Continuar?")
		cRiscoI	:=BOM->BOM_GRARIS 
		cRiscoF :=M->BOM_GRARIS
		RecLock("BOM",.F.)
		BOM->BOM_GRARIS := M->BOM_GRARIS
		BOM->(MsUnlock())
		
		dbSelectArea("BOQ")
		BOQ->(DbSetOrder(2))//BOQ_FILIAL, BOQ_VIDA, BOQ_ELEGIB
		
		If BOQ->(MsSeek(xFilial("BOQ") + cVida+cSeqEle))
			While !BOQ->(EOF()) .And. BOQ->(BOQ_VIDA+BOQ_ELEGIB) == cVida+cSeqEle
				If BOQ->BOQ_DATSUG >= dDataBase .And. (BOQ->BOQ_STATUS == '0' .Or. BOQ->BOQ_STATUS == '1')//0=Incluido;1=Lib Agenda;2=Agendado; 3=Realizado;4=Nao Realizado
					RecLock("BOQ",.F.)
					BOQ->BOQ_RISCO := M->BOM_GRARIS
					BOQ->(MsUnlock())
				EndIf
				
				BOQ->(dbSkip())
			EndDo
		EndIf
		
				BOK->(RECLOCK("BOK",.T.))
				BOK->BOK_FILIAL		:=	XFILIAL("BOK")
				BOK->BOK_SEQNRO		:= GETSXENUM('BOK','BOK_SEQNRO',, 1)
				BOK->BOK_NROSEQ		:= cSeqEle
				BOK->BOK_CODPRO		:= BOM->BOM_CODPRO
				BOK->BOK_TPHIST		:="1"
				BOK->BOK_GRARII		:=cRisco
				BOK->BOK_GRARIF		:=cRiscof
				BOK->BOK_DATA			:=dDataBase
				BOK->BOK_HORA			:=Time()
				BOK->BOK_USUARI		:=cUserName
				BOK->BOK_LOGARQ		:=Hs_LogArq()
				BOK->(MSUNLOCK())
				ConfirmSx8()
  	Else
		M->BOM_GRARIS := cRisco
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPBusRegra  บAutor  ณ TOTVS              บ Data ณ 12/04/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ retorna o codigo das regras de um programa de saude        บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PBusRegra(cProg)
Local aArea 	:= GetArea()
Local aRegras	:= {}

BOC->(DbSetOrder(1))
If BOC->(MsSeek(xFilial("BOC")+cProg))
	While !BOC->(Eof()) 
		If BOC->BOC_CODPRO == cProg
			AADD(aRegras, {BOC->BOC_REGRA, BOC->BOC_RISCO})
		EndIf
		BOC->(DbSkip())
	EndDo
EndIf

aRegras := aSort(aRegras,,, {|x,y| x > y })  // Organiza por Risco maior para o menor

RestArea(aArea)
Return(aRegras)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPPrExeRegr บAutor  ณ TOTVS              บ Data ณ 12/04/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Executa a inclusใo de paciente elegivel por programa/regra บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function PPrExeRegr(cCdProg, cRegra, aEncontr, oProcess)
Local aArea 	 := GetArea()
Local cSqlExec	 := ""
Local nCount	 := 0
Local cVida  	 := ""
Local cScore  	 := ""
Local lPontu  	 := .F.
Local lTipo  	 := .F.
Local lGrvEleg 	 := .F.
Local nQtdSUK 	 := 0
Local nQtdPont	 := 0
Local nC    	 := 0
Local nCont    	 := 0
Local aCampan    := {}
Local cCodCamp   := ""

Default aEncontr := {}

DbSelectArea("BOP")
BOP->(DbSetOrder(1))
If BOP->(MsSeek(xFilial("BOP") + cRegra ))
	While !BOP->(EOF()) .And. cRegra == BOP->BOP_ITEREG
		If  BOP->BOP_TIPELE == '3'
			lPontu := .T.
			AADD(aCampan, BOP->BOP_DADO)
		Else
			lTipo := .T.
		EndIf
		BOP->(dbSkip())
	EndDo
EndIf

BOC->(DbSetOrder(1))
BOC->(MsSeek(xFilial("BOC") + cCdProg + cRegra))

cSqlExec := PPROEXSQL(cCdProg, cRegra,@nQtdPont)
cSqlExec  := ChangeQuery(cSqlExec)

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Inicio da busca Programa [" + cCdProg + "] regra [" + cRegra + "] -> " + Time() , 0, 0, {})

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlExec),"TRBTMP",.F.,.T.)
dbSelectArea("BOM")
BOM->(dbSetOrder(3)) //BOM_FILIAL, BOM_VIDA, BOM_STATUS
If oProcess <> Nil
	oProcess:IncRegua2("Executando busca regra ["+ Alltrim(BOC->BOC_DREGRA) +"]")
EndIf

If !TRBTMP->(Eof())
	While !TRBTMP->(Eof())
		Begin Transaction
		
		//If !Empty(TRBTMP->PROLOCAL) .And. cVida <> TRBTMP->BTS_MATVID
		//Retirada condi็ใo pois quando vem do call center nao tem local e como esta elegendo pode gravar sem local.
		If lPontu
			cVida := TRBTMP->BTS_MATVID
			If BOM->(!MsSeek(xFilial("BOM") + Alltrim(TRBTMP->BTS_MATVID)))
				While !TRBTMP->(Eof()) .And. cVida == TRBTMP->BTS_MATVID
					cScore += TRBTMP->SCORE
					If TRBTMP->SCORE == '1'
						nQtdSUK ++ //ESTA VARIAVEL VALIDA A QUANTIDADE DE ELEGIBILIDADE DO TIPO PONTUAวรO QUE FOI CADASTRADA NO PROGRAMA
						//caso seja cadastrada mais de uma pontua็ao o sistema varre a BOP comparando o campo BOP_DADO com as campanhas existentes na quary para poder alimentar a tabela de movimenta็ใo BOM
						For nC := 1 To Len(aCampan)
							If TRBTMP->ACI_CODSCR == AllTrim(aCampan[nC]) .And. nCont < Len(aCampan) .And. cCodCamp <> TRBTMP->ACI_CODSCR
								nCont ++
							EndIf
						Next nC
					EndIf
					cCodCamp := TRBTMP->ACI_CODSCR
					TRBTMP->(DbSkip())
				EndDo
				
				If nCont == Len(aCampan)
					If lTipo
						If "0" $ cScore .And. "1" $ cScore .And. nQtdSUK >= nQtdPont
							lGrvEleg := .T.
						EndIf
					ElseIf "1" $ cScore .And. nQtdSUK >= nQtdPont
						lGrvEleg := .T.
					EndIf
				EndIf
				
				
				nQtdSUK := 0
				nCont   := 0
				
				If lGrvEleg
					nCount ++
					Reclock("BOM",.T.)
					
					BOM->BOM_FILIAL 	:= xFilial("BOM")
					BOM->BOM_CODPRO 	:= cCdProg
					BOM->BOM_VIDA   	:= cVida
					BOM->BOM_NOME   	:= Posicione("BTS",1,xFilial("BTS") +  cVida, "BTS_NOMUSR")
					If Type("TRBTMP->DATPROC") <> "U"
				   		BOM->BOM_DTELEG 	:= STOD(TRBTMP->DATPROC) //dDataBase
				   	Else
					BOM->BOM_DTELEG 	:= dDataBase
				   	Endif
					//BOM->BOM_MEDRSP 	:= cCodCrm
					BOM->BOM_STATUS 	:= "0" // Elegivel
					BOM->BOM_GRARIS 	:= BOC->BOC_RISCO
					BOM->BOM_ORIGEM 	:= FunName() // Rotina de origem
					BOM->BOM_USUARI 	:= cUserName // Usuario logado
					BOM->BOM_LOGARQ 	:= Hs_LogArq() // Usuario logado
					BOM->BOM_NROSEQ 	:= cSeqBOM := GetSXENUM('BOM','BOM_NROSEQ',, 1)
					BOM->BOM_VIP		:= IIf(Empty(TRBTMP->BA1_USRVIP), "0",TRBTMP->BA1_USRVIP)//PLSRetVIP(TRBTMP->BTS_MATVID)//BA1_USRVIP
					BOM->BOM_MOTELE	:= Alltrim(BOC->BOC_DREGRA) //cQryDsCond//PlRetMBOC(TRBTMP->BOC_ITECND)
					
					If !Empty(TRBTMP->PROLOCAL)
						If Len(Alltrim(TRBTMP->PROLOCAL)) == 2 .AND. HS_EXISDIC({{"C", "GCS_LOCPLS"}},.F.)
							GCS->(DbSetOrder(1))
							If GCS->(MsSeek(xFilial("GCS") + Alltrim(TRBTMP->PROLOCAL)))
								BOM->BOM_CODLOC := GCS->GCS_LOCPLS
							EndIf
						Else
							BOM->BOM_CODLOC	    := TRBTMP->PROLOCAL
						EndIf
					EndIf
					
					MsUnlock()
					ConfirmSx8()
					
				EndIf
			EndIf
		Else
			If cVida <> TRBTMP->BTS_MATVID
				If BOM->(!MsSeek(xFilial("BOM") + Alltrim(TRBTMP->BTS_MATVID)))
					nCount ++
					Reclock("BOM",.T.)
					BOM->BOM_FILIAL 	:= xFilial("BOM")
					BOM->BOM_CODPRO 	:= cCdProg
					BOM->BOM_VIDA   	:= TRBTMP->BTS_MATVID
					BOM->BOM_NOME   	:= Posicione("BTS",1,xFilial("BTS") +  TRBTMP->BTS_MATVID, "BTS_NOMUSR")
						If Type("TRBTMP->DATPROC") <> "U"
				   			BOM->BOM_DTELEG 	:= STOD(TRBTMP->DATPROC)//dDataBase
				   		Else
					BOM->BOM_DTELEG 	:= dDataBase
				   		Endif	
					BOM->BOM_STATUS 	:= "0" // Elegivel
					BOM->BOM_GRARIS 	:= BOC->BOC_RISCO
					BOM->BOM_ORIGEM 	:= FunName() // Rotina de origem
					BOM->BOM_USUARI 	:= cUserName // Usuario logado
					BOM->BOM_LOGARQ 	:= Hs_LogArq() // Usuario logado
					BOM->BOM_NROSEQ 	:= cSeqBOM := GetSXENUM('BOM','BOM_NROSEQ',, 1)
					BOM->BOM_VIP		:= IIf(Empty(TRBTMP->BA1_USRVIP), "0",TRBTMP->BA1_USRVIP)//PLSRetVIP(TRBTMP->BTS_MATVID)//BA1_USRVIP
					BOM->BOM_MOTELE	:= Alltrim(BOC->BOC_DREGRA) //cQryDsCond//PlRetMBOC(TRBTMP->BOC_ITECND)
					
					If !Empty(TRBTMP->PROLOCAL)
						If Len(Alltrim(TRBTMP->PROLOCAL)) == 2 .AND. HS_EXISDIC({{"C", "GCS_LOCPLS"}},.F.)
							GCS->(DbSetOrder(1))
							If GCS->(MsSeek(xFilial("GCS") + Alltrim(TRBTMP->PROLOCAL)))
								BOM->BOM_CODLOC := GCS->GCS_LOCPLS
							EndIf
						Else
							BOM->BOM_CODLOC	    := TRBTMP->PROLOCAL
						EndIf
					EndIf
					
					MsUnlock()
					ConfirmSx8()
					cVida := TRBTMP->BTS_MATVID
				EndIf
			EndIf
			TRBTMP->(DbSkip())
		EndIf
		
		End Transaction
		cScore   := ""
		cCodCamp := ""
		lGrvEleg := .F.
	EndDo
	
	If nCount > 0
		AADD(aEncontr, nCount)
	EndIf
	
EndIf

TRBTMP->(DbCloseArea())
FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Fim da busca Programa [" + cCdProg + "] regra [" + cRegra + "] -> " + Time() , 0, 0, {})

RestArea(aArea)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_BOClik  บAutor  ณ                    บ Data ณ 20/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para marcar e desmarcar o item.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_BOClik(oBOC)

oBOC:aCols[oBOC:oBrowse:nAt, nBOCIDMARK] := IIf(oBOC:aCols[oBOC:oBrowse:nAt, nBOCIDMARK] == "LBTIK", "LBNO", "LBTIK")
oBOC:oBrowse:Refresh()  

Return(Nil)                                                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_EXCPLANบAutor  ณ                    บ Data ณ 20/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณExclui planejamento futuro e em aberto para alta do programa.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_EXCPLAN(cVida,cEleg)           
Local aArea := GetArea()
DbSelectArea("BOQ")
DbSetOrder(2)   
If BOQ->(MsSeek(xFilial("BOQ") + cVida+cEleg))
	While !BOQ->(Eof()) .AND. BOQ->BOQ_ELEGIB == cEleg    
		If BOQ->BOQ_STATUS $ "01" 
			RecLock("BOQ", .F., .F. )
			DbDelete()
			MsUnlock()
			WriteSx2("BOQ")  		
		EndIf
		BOQ->(DbSkip())
	EndDo
EndIf
RestArea(aArea)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSConLoc  บAutor  ณMicrosiga         บ Data ณ  07/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ao para retornar a descri็ao do local.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PLSConLoc(cCodLoc)
Local cDesLoc := ""

cDesLoc := Posicione('BD1',1,xFilial('BD1')+PlsIntPad()+cCodLoc,'BD1_DESLOC')      

Return cDesLoc
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPPTRANSF   บAutor  ณMicrosiga         บ Data ณ  04/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a Transferencia do Paciente para outro setor       บฑฑ
ฑฑบ          ณ de atendimento                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function PPTRANSF(cVida,cSeqPro)
	Local aArea := GetArea()
	Local cPerg 	:= PADR("PMPRO05", Len(SX1->X1_GRUPO))
	Local cLocal	:=""
	Local cLocalI	:=""
	DEFAULT cVida	:=""
	DEFAULT cSeqPro :=""


	If !Pergunte(cPerg,.T.)
		Return()
	EndIf

	cLocal := MV_PAR01

	If Empty(cLocal)
		MsgInfo("Local nao informado!")
		Return()
	EndIf

	BOM->(DbSetOrder(2))
	If BOM->(MsSeek(xFilial("BOM") + cSeqPro))
		If BOM->BOM_STATUS == '1' .Or. BOM->BOM_STATUS == '3'
			cLocalI	:=BOM->BOM_CODLOC
			BOM->(RecLock("BOM",.F.))
			BOM->BOM_CODLOC	 := cLocal
			BOM->(MsUnLock())
			
			BOQ->(DbSetOrder(2))
				If BOQ->(MsSeek(xFilial("BOQ") + cVida+cSeqPro))
					While !BOQ->(EOF()) .And. BOQ->(BOQ_VIDA+BOQ_ELEGIB) == cVida+cSeqPro
							RecLock("BOQ",.F.)
							BOQ->BOQ_CODLOC := cLocal
							BOQ->(MsUnlock())

				
					BOQ->(dbSkip())
					EndDo
				EndIf

			BOK->(RECLOCK("BOK",.T.))
			BOK->BOK_FILIAL		:=	XFILIAL("BOK")
			BOK->BOK_SEQNRO		:= GETSXENUM('BOK','BOK_SEQNRO',, 1)
			BOK->BOK_NROSEQ		:= cSeqPro
			BOK->BOK_CODPRO		:= BOM->BOM_CODPRO
			BOK->BOK_TPHIST		:="0"
			BOK->BOK_CODLOI		:=cLocalI
			BOK->BOK_CODLOF		:=cLocal
			BOK->BOK_DATA			:=dDataBase
			BOK->BOK_HORA			:=Time()
			BOK->BOK_USUARI		:=cUserName
			BOK->BOK_LOGARQ		:=Hs_LogArq()
			BOK->(MSUNLOCK())
			ConfirmSx8()


		Else
			MsgInfo("Para que seja possivel Transferir o paciente ele deve estar Inscrito no Programa ou possuir Pendencias.")
		EndIf
	ELSE
		MsgInfo("Nใo foi Selecionado Nenhum Paciente da Promo็ใo Da Saude ")
		Return()
	EndIf

	RestArea(aArea)
Return()



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PMPRORISCO  บAutor  ณMicrosiga         บ Data ณ  23/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a Mudan็a do Grau de Risco na anamnese.           บฑฑ
ฑฑบ          ณ 			                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function PMPRORISCO(cVida,cProgr)
Local cCadastro 	:= "Altera็ใo no Grau da Classifica็ใo de Risco"  
Local cChave    	:= ""
Local oHist     	:= ""
Local cHist     	:= ""
Local aSize     	:= {}              
Local aObjects  	:= {}
Local aPPanel   	:= {}
Local nOpcA     	:= 0
Local aAreaBOK  	:= BOK->(GetArea())
Local lPassou   	:= .F.
Local nPVida    	:= 0
Local nPData    	:= 0
Local nPHora    	:= 0
Local nPTel     	:= 0
Local nPHist    	:= 0
lOCAL nTamNome		:=0
Local cNome		:=""
Local oProd
Local cRisco 		:= Space(TamSx3("BOB_GRAU")[1]) 

Private aTela   	:= {}
Private aGets   	:= {}
Private aCols		:= {}
Private aHeader 	:= {}
Private nUBOK   	:= 0
Private oFolder 	:= 0
Private nLBOK   	:= 0
Private OBOK

                                        
aSize	:= MsAdvSize(.T.)
   
aAdd( aObjects, { 100, 020, .T., .T.} ) 
aAdd( aObjects, { 100, 070, .T., .T.} ) 
aAdd( aObjects, { 100, 010, .T., .T.} )                                               
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T.)

dbselectarea("BOM")
dbsetorder(1)
If !(BOM->(MsSeek(xFilial("BOM")+cProgr+cVida+"1")))
			MsgInfo("Para que seja possivel Alterar o Grau de Risco do paciente ele deve estar Inscrito no Programa.")
		RETURN()

Endif
DEFINE MSDIALOG oDlgBOK TITLE cCadastro From 000, 000 To 250, 350 Of oMainWnd Pixel   


DEFINE FONT oFontPen NAME "Arial" SIZE 12,24 BOLD
	DEFINE FONT oFontNome NAME "Arial" SIZE 06,24 BOLD
	@005, 005 Say "Risco: "  Of oDlgBOK Pixel COLOR CLR_BLUE 
	@ 003, 050 MsGet oProd VAR cRisco Size 40, 009 VALID /*PlsVldBob(cProgr)*/ F3 "BOBPAK" OF oDlgBOK Pixel COLOR CLR_BLACK
	@025, 005 Say "Motivo da Mudan็a do Grau da Classifica็ใo de Risco" Of oDlgBOK Pixel COLOR CLR_BLUE 
	@033, 005 GET oHist VAR cHist MEMO SIZE 150, 050 Of oDlgBOK WHEN Empty(cHist) Pixel Color CLR_BLACK
	
	oBtnFil := tButton():New(95, 045,"Sair"	, oDlgBOK, {||oDlgBOK:End()}, 030, 012,,,, .T.)
	oBtnFil :=	tButton():New(95, 005, "Gravar" , oDlgBOK, {|| GravaBoK(cProgr,cVida,cHist,cRisco), , oDlgBOK:End()}, 030,012,,,, .T.) 	
	ACTIVATE MSDIALOG oDlgBOK
		
Return(NIL)    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GravaBoK  บAutor  ณMicrosiga         บ Data ณ  23/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava a Tabela de Historico de Movimenta็ใo.           บฑฑ
ฑฑบ          ณ 			                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function GravaBoK(cProgram,cMatVid,cHist,cRisco)
Local aArea 		:= GetArea()
Local cRiscoI		:=""
Local cSeqPro		:=""

Default cProgram	:=""
Default cMatVid	:=""
Default cHist		:=""
Default cRisco		:="" 

dbSelectArea("BOM")
BOM->(dbSetOrder(1))//BOM_FILIAL, BOM_CODPRO, BOM_VIDA, BOM_STATUS
If BOM->(MsSeek(xFilial("BOM") + cProgram+cMatVid+"1" ) )
				cSeqPro	:=BOM->BOM_NROSEQ
				cRiscoI	:=BOM->BOM_GRARIS
				
				BOM->(RecLock("BOM",.F.))
				BOM->BOM_GRARIS	 := cRisco
				BOM->(MsUnLock())
				
				BOQ->(DbSetOrder(2))
				If BOQ->(MsSeek(xFilial("BOQ") + cMatVid+cSeqPro)) //BOQ_FILIAL, BOQ_VIDA, BOQ_ELEGIB, R_E_C_N_O_, D_E_L_E_T_
					While !BOQ->(EOF()) .And. BOQ->(BOQ_VIDA+BOQ_ELEGIB) == cMatVid+cSeqPro
						If BOQ->BOQ_DATSUG >= dDataBase .And. (BOQ->BOQ_STATUS == '0' .Or. BOQ->BOQ_STATUS == '1')//0=Incluido;1=Lib Agenda;2=Agendado; 3=Realizado;4=Nao Realizado
							RecLock("BOQ",.F.)
							BOQ->BOQ_RISCO := cRisco
							BOQ->(MsUnlock())
						Endif
					BOQ->(dbSkip())	
					EndDo
				EndIf
				
				BOK->(RECLOCK("BOK",.T.))
				BOK->BOK_FILIAL		:=	XFILIAL("BOK")
				BOK->BOK_SEQNRO		:= GETSXENUM('BOK','BOK_SEQNRO',, 1)
				BOK->BOK_NROSEQ		:= cSeqPro
				BOK->BOK_CODPRO		:= BOM->BOM_CODPRO
				BOK->BOK_TPHIST		:="1"
				BOK->BOK_GRARII		:=cRiscoI
				BOK->BOK_GRARIF		:=cRisco
				BOK->BOK_DATA			:=dDataBase
				BOK->BOK_HORA			:=Time()
				BOK->BOK_USUARI		:=cUserName
				BOK->BOK_LOGARQ		:=Hs_LogArq()
				BOK->BOK_MOTIVO		:=cHist
				BOK->(MSUNLOCK())
				ConfirmSx8()

		RestArea(aArea)
	
Endif

Return(.t.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PMPROHIST  บAutor  ณMicrosiga         บ Data ณ  23/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe as Mudan็a do Grau de Risco e de Setor.           บฑฑ
ฑฑบ          ณ 			                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function PMPROHIST(cSeqBom)
Local    cPerg 	:= PADR("PMPRO06", Len(SX1->X1_GRUPO))
Local    cTipo	:=""
Local    cCampos:="" 
Default  cSeqBom:=""

If !Pergunte(cPerg,.T.)
	Return()
EndIf
cTipo:= str(MV_PAR01)  
If alltrim(cTipo)=="1"
	cTipo:="0"			
	cCampos:="BOK_CODPRO/BOK_SEQNRO/BOK_NROSEQ/BOK_TPHIST/BOK_CODLOI/BOK_LOCALI/BOK_CODLOF/BOK_LOCALF/BOK_DATA/BOK_HORA/BOK_USUARI/BOK_LOGARQ"
Else
	cTipo:="1"
	cCampos:="BOK_CODPRO/BOK_SEQNRO/BOK_NROSEQ/BOK_TPHIST/BOK_GRARII/BOK_CLARII/BOK_GRARIF/BOK_CLARIF/BOK_MOTIVO/BOK_DATA/BOK_HORA/BOK_USUARI/BOK_LOGARQ"			
Endif
PLGRVDIAG("BOK","HISTORICO ALTERAวีES", " BOK.BOK_NROSEQ = '" + cSeqBom + "' AND BOK.BOK_TPHIST = '" + cTipo + "'  ", /*cCpoID*/, /*xDadoId*/, 1, "BOK_FILIAL+BOK_NROSEQ", /*aCampos*/, 0/* nOpcGD*/, /*cFunPosOK*/, /*nAltDiag*/, /*nLargDiag*/, /*aButAR*/, /*lCpoSequen*/, /*lB7D*/, /*cFunDel*/,cCampos,.T.,"BOK_SEQNRO DESC ")	

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PMHISTBRIN  บAutor  ณMicrosiga         บ Data ณ  23/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe os brindes emitidos nos Eventos da Campanha           บฑฑ
ฑฑบ          ณ 			                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function PMHISTBRIN(cVida,cProgram)
PLGRVDIAG("BO7","Brindes por Campanha", " BO7.BO7_MATVID = '" + cVida + "' AND BO7.BO7_CODPRO = '" + cProgram + "'  ", /*cCpoID*/, /*xDadoId*/, 1, "BO7_FILIAL+BO7_SEQNRO", /*aCampos*/, 0/* nOpcGD*/, /*cFunPosOK*/, /*nAltDiag*/, /*nLargDiag*/, /*aButAR*/, /*lCpoSequen*/, /*lB7D*/, /*cFunDel*/,/*cCampos*/,.T.,"BO7_SEQNRO DESC ")
Return()
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PMHISTSIN  บAutor  ณMicrosiga         บ Data ณ  23/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe as Despesas X Custos emitidos 					      บฑฑ
ฑฑบ          ณ 			                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function PMHISTSIN(cVida,cProgram,dDataDe,dDataAte,lTprog)
Local aDadosBx9:={}
Local cAno 	  	:= 	""
Local cAnoAte 	:= 	""
Local cMes 	  	:= 	""
Local cMesAte 	:=	""
Local cAlias	:="BA1"
Local cAliasCab	:="BA1"
Local aDados	:={}
Local aCab		:={}
Local aTipoCab	:={}
Local nCtaFor1	:=0
Local nCtaFor	:=0
Local nCtaLn	:=0
Local cdados	:=""
Local aDadosTot	:={}
local n2	:=0
local ni	:=0
local aGraph:={}
Local cDesc2:=""

Local aArea	    	:= getArea()
local aGrafg	:={}
Local aTitu:={}
Local cNome	:=""
Local cdescPro:=""
Local ndados:=0
Local nCtaDad:=0
Local aLenCpos:={}
Local cSqlIn	:=""
Local cEmpresa	:=""

Default cVida		:=""
Default cProgram	:=""
Default dDataDe 	:= cTod('')
Default dDataAte	:= cTod('')
Default lTProg		:=.T. //Todos do programa


//If FunName() == "PLSMPROM"
cProgram	:=BOA->BOA_CODPRO

If dDataDe==cTod('') 	 
	 dDataDe 	:= BOA->BOA_DATINI
Endif

If dDataAte == cTod('')
	 dDataAte	:= BOA->BOA_DATFIM
EndIf 

If !Empty(cVida)
	cNome:=Posicione("BTS",1,xFilial("BTS") +  cVida, "BTS_NOMUSR")
Endif                                                                      
If !Empty(cProgram)
	cdescPro:=Posicione("BOA",1,xFilial("BOA") +  cProgram, "BOA_DESPRO")
Endif

If (dDataDe==cTod('') .or. dDataAte == cTod(''))
	MsgInfo("Data Inicio e Fim do Programa nใo estใo preenchidas  ")
	RestArea(aArea)
	Return()
Endif

IF lTProg
	DbSelectArea("BOM")
	DbSetOrder(1) //BOM_FILIAL, BOM_CODPRO, BOM_VIDA, BOM_STATUS, R_E_C_N_O_, D_E_L_E_T_
	DbSeek(xFilial("BOM")+cProgram)
	BOM->(DbGoTop())

	While BOM->(! EOF() .And. BOM->(BOM_FILIAL) + BOM->(BOM_CODPRO) == ;
		xFilial("BOM")+cProgram)
		cVida:=	BOM->BOM_VIDA
		DbSelectArea("BA1")
		DbSetOrder(7) //BA1_FILIAL, BA1_MATVID
		DbSeek(xFilial("BA1")+cVida)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณBusca Dados					ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		While BA1->(! EOF() .And. BA1->(BA1_FILIAL + BA1_MATVID) == ;
			xFilial("BA1")+cVida)
			aadd(aLenCpos,BA1->BA1_CODEMP +BA1->BA1_CONEMP +BA1->BA1_VERCON +BA1->BA1_SUBCON +BA1->BA1_VERSUB+BA1->BA1_MATRIC +BA1->BA1_TIPREG)
			BA1->(dbskip())
		Enddo

		BOM->(dbskip())
	Enddo      
	
	
	If ValType(aLenCpos) <> "A"
		MsgInfo("Nใo existem dados para serem exibidos")
		RestArea(aArea)
		Return()
	 Endif
	
	 If  len(aLenCpos) == 0
		MsgInfo("Nใo existem dados para serem exibidos")
		RestArea(aArea)
		Return()
	 Endif

	for nI:=1 to len(aLenCpos)
		cEmpresa += "'" + aLenCpos[nI] + "'"
		if nI< len(aLenCpos)
			cEmpresa += ","
		endif
	next nI   
   
	cSqlIn := "AND BX9_CODEMP+BX9_CONEMP+BX9_VERCON+BX9_SUBCON+BX9_VERSUB+BX9_MATRIC+BX9_TIPREG IN (" + cEmpresa + ") 
	cSqlIn += "AND BX9_TIPO   = '5' "
	aDadosBx9:={}
	aDadosBx9:=PLS790BX9(dDataDe,dDataAte,cAlias,cAliasCab,"" ,"" ,"" ,"" ,"" ,"","" ,"",/*cAno*/ ,/*cAnoAte*/ ,/*cMes*/,/*cMesAte*/,.F.,5,cSqlIn )
	aadd(aDadosTot,aDadosBx9)



Else
	DbSelectArea("BA1")
	DbSetOrder(7) //BA1_FILIAL, BA1_MATVID
	DbSeek(xFilial("BA1")+cVida)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBusca Dados					ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	While BA1->(! EOF() .And. BA1_FILIAL + BA1_MATVID == ;
		xFilial("BA1")+cVida)
		aDadosBx9:={}
		aDadosBx9:=PLS790BX9(dDataDe,dDataAte,cAlias,cAliasCab,BA1->BA1_CODINT ,BA1->BA1_CODEMP ,BA1->BA1_CONEMP ,BA1->BA1_VERCON ,BA1->BA1_SUBCON ,BA1->BA1_VERSUB,BA1->BA1_MATRIC ,BA1->BA1_TIPREG,/*cAno*/ ,/*cAnoAte*/ ,/*cMes*/,/*cMesAte*/,.F.,5,.F. )
		aadd(aDadosTot,aDadosBx9)
		BA1->(dbskip())
	Enddo

Endif

If ValType(aDadosTot) <> "A"
	MsgInfo("Nใo existem dados para serem exibidos")
	RestArea(aArea)
	Return()
Endif
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta Dados/cabec MES/ANO      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For  ni:=1 to len(aDadosTot)
	aadd(aDados,aDadosTot[ni][1])
	aadd(aCab,aDadosTot[ni][2])
	aadd(aTipoCab,aDadosTot[ni][2])
Next ni


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLoop de Impressao dos dados    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If (ValType(adados) <> "A" .or. len(adados) == 0)
	MsgInfo("Nใo existem dados para serem exibidos")
	RestArea(aArea)
	Return()
Endif


If ValType(adados[1]) <> "A" 
	MsgInfo("Nใo existem dados para serem exibidos")
	RestArea(aArea)
	Return()
Endif

If Len(adados[1])==0
	MsgInfo("Nใo existem dados para serem exibidos")
	RestArea(aArea)
	Return()
Endif 

ProcRegua(Len(aDados))  // seta o tamanho da regua

For nCtaFor := 1 to Len(adados[1][nCtaFor])
	If  !(nCtaFor <3 .or. nCtaFor == 6)
		loop
	Endif
	For nCtaLn := 1 to len(adados[1][nCtaLn])
		If nCtaLn<4 .and. nCtaFor #126
			loop
		Endif
		
		If Valtype(aDados[1,nCtaFor, nCtaLn] )=="C"
			cDesc2 :=aCab[1][nCtaLn][1]
			cdados := PadR((iif(empty(aDados[1,nCtaFor, nCtaLn]),space(len(aDados[1,nCtaFor, nCtaLn])),aDados[1,nCtaFor, nCtaLn])),15)
			AADD(aGraph, {cDesc2,cdados,nCtaLn,nCtaFor})
		ElseIf Valtype(aDados[1,nCtaFor, nCtaLn] )=="U" .and. nCtaLn ==1
			cDesc2 :=aCab[1][nCtaLn][1]
			cdados := Padl("",15)
			AADD(aGraph, {cDesc2,cdados,nCtaLn,nCtaFor})
		ElseIf Valtype(aDados[1,nCtaFor, nCtaLn] )=="U"
			cDesc2 :=aCab[1][nCtaLn][1]
			cdados := Padl(Transform(0,"@E 999,999,999.99"),14)
			AADD(aGraph, {cDesc2,cdados,nCtaLn,nCtaFor})
		Else
			If nCtaLn==3
				loop
			Else
				cDesc2 :=aCab[1][nCtaLn][1]
				cdados := Padl(Transform(aDados[1,nCtaFor, nCtaLn],"@E 999,999,999.99"),14)
				AADD(aGraph, {cDesc2,cdados,nCtaLn,nCtaFor})
			Endif
		Endif
		
	Next nCtaLn
	
	If Len(aGraph) > 0  .and. nCtaFor==2
		aadd(aGrafg,{aGraph})
		aadd(aTitu,{"Receita X Custos"})
		aGraph:={}
		cdados :=""
		cDesc2:=""
	ElseIf Len(aGraph) > 0  .and. nCtaFor==6
		aadd(aGrafg,aGraph)
		aadd(aTitu,{aDados[1,nCtaFor, 2]})
		aGraph:={}
		cdados :=""
		cDesc2:=""
	EndIf
	
Next nCtaFor

PProMntGraf( ,aGrafg, "4","Sinistralidade " /*aDados[1,nCtaFor, 2]*/,.T.,aTitu,cNome,cdescPro,dDataDe)
RestArea(aArea)

Return()

