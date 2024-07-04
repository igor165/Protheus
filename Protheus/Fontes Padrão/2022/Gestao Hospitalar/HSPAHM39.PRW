#INCLUDE "HSPAHM39.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

// Para medir o desenpenho dessa rotina basta desabilitar as linhas com o marcador [DESEMP].
//Static __cTime := Time()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ HSPAHM39 ³ Autor ³ Paulo Emidio de Barros³ data ³ 02/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Agenda Cirurgica                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³ Gestao Hospitalar                         				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM39()            

Local bKeyF12 := SetKey(VK_F12, {|| FS_FilM39(.T.)})

Private cCadastro  := OemToAnsi(STR0001) //"Agenda Cirurgica"
Private lFilGm1    := .T.   
Private cGcsTipLoc := "6"
Private cGcsCodLoc := ""
Private cGD4RegGer := Space(Len(GD4->GD4_REGGER))        //Campo utilizado na consulta padrao GD4
Private cFilM39    := ""
Private aCposUsu   := {} 
Private aCorM39    := {{"GMJ->GMJ_STATUS == '0'", "BR_VERDE"   }, ;  //Horario Livre
                       {"GMJ->GMJ_STATUS == '1'", "BR_VERMELHO"}, ; //Horario Ocupado
                       {"GMJ->GMJ_STATUS == '2'", "BR_AMARELO" }, ; //Horario Bloqueado
                       {"GMJ->GMJ_STATUS == '3'", "BR_AZUL"    }}   //Horario Atendido
Private aRotina    := MenuDef()
     

If FS_FilM39(.F.)
	mBrowse(06, 01, 22, 75, "GMJ",,,,,, aCorM39,,,,,,,, cFilM39)
EndIf 

SetKey(VK_F12, bKeyF12)
 
Return(Nil)   

                              

Static Function FS_FilM39(lSetFilter)

Local lRet     := .F.
Local oObjMBrw := GetObjBrow()

If (lRet := Pergunte("HSPM39"))
	cFilM39 := "GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ_DATAGE >= '" + DToS(dDataBase) + "' AND "
	If ValType(MV_PAR02) == "N"
		If MV_PAR02 == 1
			cFilM39 += "GMJ_STATUS = '1' AND GMJ_CODAGE = GMJ_SEQAGE"
		ElseIf MV_PAR02 == 2
			cFilM39 += "GMJ_STATUS = '3' AND GMJ_CODAGE = GMJ_SEQAGE"
		Else
			cFilM39 += "(GMJ_STATUS = '1' OR GMJ_STATUS = '3') AND GMJ_CODAGE = GMJ_SEQAGE"
		EndIf
	Else
		cFilM39 += "GMJ_STATUS = '1' OR GMJ_STATUS = '3' AND GMJ_CODAGE = GMJ_SEQAGE"
	EndIf		
	If lSetFilter
		MsgRun(STR0035, STR0036, {|| SetMBTopFilter("GMJ", cFilM39), oObjMBrw:GoTop(), oObjMBrw:Refresh()}) //"Selecionando os Agendamentos..."###"Aguarde..."
	EndIf
	cGcsCodLoc := MV_PAR01  //Setor selecionado 
EndIf

DbSelectArea("GMJ")
 
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HS_M39Atu³ Autor ³Paulo Emidio de Barros ³ Data ³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Agendamento Cirurgico   					                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ HS_M39Atu(EXPC1,EXPN1,EXPN2)			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias do arquivo		                              ³±±
±±³			 ³ EXPN1 = Numero do registro 	                              ³±±
±±³		     ³ EXPN2 = Opcao selecionada		                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ HS_M39Atu 		                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                 
Function HS_M39Atu(cAliasM39, nRegM39, nOpcM39)

Local aSize := {}, aObjs := {}, aInfo := {}, aPAux := {}, aPObj := {}, aPEnc := {}, aPGet := {}, aPMem := {}
Local aTitulos := {}, aPaginas  := {}, aAgeMar := {}, aAgeLock := {}
Local cMsgAge := " ", lHelp := .F., nOpcAgd := 0
Local aHeadGEA := {}, aColsGEA := {}
Local aHeadGEB := {}, aColsGEB := {}
Local aHeadGET := {}, aColsGET := {}
Local aHeadGMJ := {}, aColsGMJ := {}
Local aHeadTrf := {}, aColsTrf := {}
Local aButtons := {{'S4WB011N', {|| HS_ConsAge("C")}, STR0076},;  // "Consulta"
                     {'CONTAINR', {|| HS_PesqEqp()}  , "Equipto."}}
Local nGDOpc :=	IIF(StrZero(nOpcM39, 2) $ "02/05/09", (GD_INSERT + GD_UPDATE + GD_DELETE), 0) 
Local oDlgAgd, oEncGmj, oFolder, oGetGEB, oFont
Local oPanCal, cPerg := "HSM39R"
Local nQtdHDis := GetNewPar("MV_QTHRAGC",48) //HSP-Define a quantidade de horário disponível para atendimento na agenda cirúrgica.
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos que deverao ser editados na Enchoice					             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCpoAlt := {"GMJ_FILAGE", "GMJ_REGGER", "GMJ_MATRIC", "GMJ_NOMPAC", "GMJ_TELPAC", "GMJ_CODPRO", "GMJ_DESPRO", "GMJ_CODPLA", "GMJ_DESPLA", ; 
                   "GMJ_CODCRM", "GMJ_NOMCRM", "GMJ_OBSERV", "GMJ_CODPAT", "GMJ_PATOLO", "GMJ_DIAGNO", "GMJ_USAUTI", "GMJ_HEMODE", "GMJ_TOPOGR", "GMJ_TEMPRO", ;
                   "GMJ_SQCATP", "GMJ_DSCATP", "GMJ_DATINT", "GMJ_IDADE ", "GMJ_PESO  " }

Local aCpoEnc    := aClone(aCpoAlt) 
Local aCpoVisGeb := {}, aCpoVisGea := {}
Local lCancResCir := GetNewPar("MV_CANCCIR",.F.) // Permite cancelar reserva cirúrgica após horário agendado.
 
If GMJ->(FieldPos("GMJ_USAEQP")) > 0 
	aAdd(aCpoAlt, "GMJ_USAEQP")
    aAdd(aCpoEnc, "GMJ_USAEQP")
EndIf

//Exibe o motivo somente nas opcoes: Cancelar e Transferir
If (nOpcM39 == 3 .Or. nOpcM39 == 4)  
	aAdd(aCpoEnc, "GMJ_MOTIVO")
	aAdd(aCpoEnc, "GMJ_DESMOT")
	aAdd(aCpoEnc, "GMJ_ORICAN")
EndIf
 
If nOpcM39 == 9
    aAdd(aCpoEnc, "GMJ_NRGUIA")
    aAdd(aCpoEnc, "GMJ_NRSEN1")
    aAdd(aCpoEnc, "GMJ_NRSEN2")
    aAdd(aCpoEnc, "GMJ_NRSEN3")
    aAdd(aCpoEnc, "GMJ_QTDIAS") 
EndIf
 
If nQtdHDis < 48 // Quantidade mínima de horarios disponiveis nao poderá ser menor que 48 horários
 	nQtdHDis := 48
EndIf
 
Private aHeadGMR := {}, aColsGMR := {}                         
Private oCalSala, oGetGET, oGetGEA, oGetGMJ, oGetTrf, oGetGMR, oGetTrab, aHeadTrab :={}, aColsTrab :={}
Private oGetGE9, aHeadGE9 := {}, aColsGE9	:= {}, lMontaEqp := (nOpcM39 == 2), lAgendar := (nOpcM39 == 2)
Private nGe9Item   := 0, nGe9CodCrm := 0, nGe9NomMed := 0, nGe9TipAtm := 0, nGe9DesAto := 0
Private nGeaCodPro	:= 0, nGeaItem   := 0, nUGEA := 0
Private nGebCodMat	:= 0, nGebItem   := 0
Private nGetCodPro := 0, nGetCodGrp := 0, nGetCodEqp := 0, nGetIteAge := 0, nGetDesGrp := 0, nGetDesEqp := 0
Private nGetDatAge := 0, nGetHorAge := 0, nGetDatFin := 0, nGetHoraFi := 0
Private nGmrCodGrp := 0, nGmrItem   := 0 
Private cObsPlano  := "", cObsProc  := "", cObsProf := ""
Private oObsPlano, oObsProc, oObsProf 
Private aGets := {}, aTela := {}, aAgeGrv := {}, aAgeTrfCan := {}
 
//Variaveis utilizadas nos filtros
Private cGbjCodEsp := Space(Len(GBJ->GBJ_ESPEC1)), cTmpCodEsp := Space(Len(GBJ->GBJ_ESPEC1)) //Campo utilizado na consulta padrao MED
Private cGavTipo   := "2"
Private cGczCodPla := Space(Len(GCZ->GCZ_CODPLA))
Private cGm7OriCan := Space(Len(GM7->GM7_ORICAN)) //Origem do Cancelamento 
Private cGr1Tipo   := "0"                         //Materias especiais
Private cGbhCodPac := Space(Len(GBH->GBH_CODPAC)) // Variavel que recebe o retorno da consulta padrão GH1 (Pacientes)
Private cGfvPlano  := ""
Private lRemaneja  := IIF(nOpcM39 == 8, .T., .F.), cSetorDe := "", cSetorAte := ""  // flag de remanejamento/realocacao
Private lTransfer  := IIF(nOpcM39 == 4, .T., .F.)
Private lPreInt    := IIF(nOpcM39 == 9, .T., .F.) // Flag de Pre Internacao
Private lEqpCCusto := IIF(AllTrim(GetMV("MV_EQPCCUS")) == "S", .T., .F.)
 
//Agenda Diaria
Private aHAgdDia   := {}
Private aCAgdDia   := {}
Private nUsuAgdDia := 0
Private oAgdDia
 
If lPreInt
	Private cAgdNomPac, cAgdTelPac, cAgdRegGer := "", cAgdCodPla := "", cAgdMatric := ""
EndIf
 
DEFINE FONT oFont NAME "Arial" SIZE 10, 20 BOLD                       
 
If lRemaneja        
	cGcsTipLoc := "4"
	If !Pergunte(cPerg, .T.)
		Return()
	EndIf
	cGcsTipLoc := "6"
	M->GMJ_FILAGE := MV_PAR01
	cSetorDe :=MV_PAR02
EndIf
 
If (nOpcM39 == 3 .Or. nOpcM39 == 4 .Or. nOpcM39 == 5 .Or. lPreInt) //Cancelar; Transferir; Alterar
	If GMJ->GMJ_STATUS == "3" //Horario Atendido
  		cMsgAge := STR0009 //"O horário selecionado já foi atendido."
	    lHelp   := .T.
    Else
	    cMsgAge := STR0010 + aRotina[nOpcM39, 01] + STR0011 //"Não será possível "###" o horário selecionado na Agenda"
	    lHelp   := GMJ->GMJ_STATUS <> "1"	
	    If (lHelp := GMJ->GMJ_DATAGE < dDataBase)
			cMsgAge += STR0012 //", com Data retroativa"
	  	ElseIf (lHelp := (GMJ->GMJ_DATAGE == dDataBase) .And. (GMJ->GMJ_HORAGE < SubStr(Time(), 01, 05)))
		    cMsgAge += STR0013 //", pois o horário já foi expirado."
	    EndIf
    EndIf 	
    If lHelp .AND. !lCancResCir  
 		HS_MsgInf(cMsgAge, STR0033, STR0001) //"Atenção"###"Agenda Cirúrgica"
 	 	Return(Nil)	
	EndIf
EndIf
 
If (nOpcM39 == 3) //Cancelar
	aCpoAlt := {"GMJ_MOTIVO", "GMJ_ORICAN", "GMJ_OBSERV"}
ElseIf (nOpcM39 == 4) //Transferir
 	aCpoAlt := {"GMJ_FILAGE", "GMJ_CODPLA", "GMJ_DESPLA", "GMJ_CODCRM", "GMJ_NOMCRM", ;
	            "GMJ_OBSERV", "GMJ_MOTIVO", "GMJ_ORICAN"}
ElseIf (nOpcM39 == 5) //Alterar
    aCpoAlt := {"GMJ_NOMPAC", "GMJ_MATRIC", "GMJ_TELPAC", "GMJ_OBSERV", "GMJ_CODPAT", "GMJ_DIAGNO", "GMJ_USAUTI", "GMJ_HEMODE", ;
                 "GMJ_TOPOGR", "GMJ_PESO"}
ElseIf lPreInt
	aCpoAlt := {"GMJ_NRGUIA", "GMJ_NRSEN1", "GMJ_NRSEN2", "GMJ_NRSEN3", "GMJ_QTDIAS"}
EndIf

//Define as Opcoes no Folder
 If lPreInt
  aTitulos := {STR0014, STR0092, STR0015 ,STR0016, STR0017, STR0018, STR0019, STR0069} //"&Atendimento"###"&Observações"###"&Equipe Médica"###"&Procedimentos"###"&Materiais Especiais"###"&Equipamentos"###"&Equipamentos Médico"

  aPaginas := {STR0020, STR0092, STR0021, STR0022, STR0023, STR0024, STR0025, STR0038} //"ATENDIMENTO"###"OBSERVAÇÕES"###"EQUIPE MÉDICA"###"PROCEDIMENTOS"###"MATERIAS ESPECIAIS"###"EQUIPAMENTOS"###"EQUIPAMENTOS MÉDICO"
 
 ElseIf lRemaneja
  aTitulos := {STR0014} //"&Atendimento"
  
  aPaginas := {STR0020} //"ATENDIMENTO"
  
 Else 
  aTitulos := {STR0014, STR0092, STR0015 ,STR0016, STR0017, STR0018, STR0019, STR0069} //"&Atendimento"###Agendamentos###"&Observações"###"&Equipe Médica"###"&Procedimentos"###"&Materiais Especiais"###"&Equipamentos"###"&Equipamentos Médico"

  aPaginas := {STR0020, STR0092, STR0021, STR0022, STR0023, STR0024, STR0025, STR0038} //"ATENDIMENTO"###Agendamentos###"OBSERVAÇÕES"###"EQUIPE MÉDICA"###"PROCEDIMENTOS"###"MATERIAS ESPECIAIS"###"EQUIPAMENTOS"###"EQUIPAMENTOS MÉDICO"

 EndIf                       
 
 // Cria as variaveis para edicao na enchoice   
 RegToMemory("GMJ", nOpcM39 == 2 .Or. lRemaneja)
 
 If !(StrZero(nOpcM39, 2) $ "02/08") .And. !Empty(M->GMJ_CODAGE) // Agendar
  aAgeGrv    := FS_BCodAge(M->GMJ_CODAGE)
  aAgeTrfCan := aClone(aAgeGrv)
 EndIf      	                          
 
 If nOpcM39 == 4 // 4-Transferencia
  HS_BDados("GMJ", @aHeadTrf, @aColsTrf,, 8,, "GMJ->GMJ_SEQAGE == '" + M->GMJ_CODAGE + "' .AND. GMJ->GMJ_SEQAGE == GMJ->GMJ_CODAGE ")
 EndIf
 
 If nOpcM39 == 5 // 5-Alterar 
 	cGczCodPla :=  M->GMJ_CODPLA
 Endif
 DbSelectArea("GMJ")
 FS_ConSala(@aHeadGMJ, nQtdHDis)
 
 If !lRemaneja

  FS_MntAgd(@aHAgdDia,@aCAgdDia,@nUsuAgdDia,IIF(nOpcM39 == 2 .Or. lRemaneja, dDataBase, M->GMJ_DATAGE))

  HS_BDados("GE9", @aHeadGE9, @aColsGE9,, 1,, IIF(!Empty(M->GMJ_CODAGE), "GE9->GE9_CODAGE == '" + M->GMJ_CODAGE + "'", Nil))

  nGe9Item   := aScan(aHeadGE9, {| aVet | aVet[2] == "GE9_ITEM  "})
  nGe9CodCrm := aScan(aHeadGE9, {| aVet | aVet[2] == "GE9_CODCRM"})
  nGe9NomMed := aScan(aHeadGE9, {| aVet | aVet[2] == "GE9_NOMMED"})
  nGe9TipAtm := aScan(aHeadGE9, {| aVet | aVet[2] == "GE9_TIPATM"})
  nGe9DesAto := aScan(aHeadGE9, {| aVet | aVet[2] == "GE9_DESATO"})
  
  If Empty(aColsGE9[1, nGe9Item])
   aColsGE9[1, nGe9Item] := StrZero(1, Len(GE9->GE9_ITEM))
  EndIf
  
  If lPreInt 
   aCpoVisGea:= {"GEA_ITEM  ", "GEA_CODPRO", "GEA_DESCPR"}
   aCpoVisGeb:= {"GEB_ITEM  ", "GEB_CODMAT", "GEB_DESCMA", "GEB_QTDMAT","GEB_QTDAUT"}
  Else
   aCpoVisGea:= {"GEA_ITEM  ", "GEA_DESCPR", "GEA_AUTORI"}
   aCpoVisGeb:= {"GEB_ITEM  ", "GEB_DESCMA", "GEB_QTDAUT"}
  EndIf
  
  HS_BDados("GEA", @aHeadGEA, @aColsGEA, @nUGEA, 1,, IIF(!Empty(M->GMJ_CODAGE), "GEA->GEA_CODAGE == '" + M->GMJ_CODAGE + "'", Nil),,,,,,,,,,,,,,,,,,,aCpoVisGea,)
 
  nGeaItem   := aScan(aHeadGEA, {| aVet | aVet[2] == "GEA_ITEM  "})
  nGeaCodPro	:= aScan(aHeadGEA, {| aVet | aVet[2] == "GEA_CODPRO"})
                                                          
  If Empty(aColsGEA[1, nGeaItem])
   aColsGEA[1, nGeaItem] := StrZero(1, Len(GEA->GEA_ITEM))
  EndIf 
  
  HS_BDados("GEB", @aHeadGEB, @aColsGEB,, 1,, IIF(!Empty(M->GMJ_CODAGE), "GEB->GEB_CODAGE == '" + M->GMJ_CODAGE + "'", Nil),,,,,,,,,,,,,,,,,,,aCpoVisGeb,)
  
  nGebItem   := aScan(aHeadGEB, {| aVet | aVet[2] == "GEB_ITEM  "})
  nGebCodMat	:= aScan(aHeadGEB, {| aVet | aVet[2] == "GEB_CODMAT"}) 
                                                          
  If Empty(aColsGEB[1, nGebItem])
   aColsGEB[1, nGebItem] := StrZero(1, Len(GEB->GEB_ITEM))
  EndIf 
  
  HS_BDados("GET", @aHeadGET, @aColsGET,, 1,, IIF(!Empty(M->GMJ_CODAGE), "GET->GET_CODAGE == '" + M->GMJ_CODAGE + "'", Nil))
  
  nGetIteAge := aScan(aHeadGET, {| aVet | aVet[2] == "GET_ITEAGE"})
  nGetCodPro := aScan(aHeadGET, {| aVet | aVet[2] == "GET_CODPRO"})
  nGetCodGrp	:= aScan(aHeadGET, {| aVet | aVet[2] == "GET_CODGRP"})
  nGetDesGrp := aScan(aHeadGET, {| aVet | aVet[2] == "GET_DESGRP"})
  nGetCodEqp	:= aScan(aHeadGET, {| aVet | aVet[2] == "GET_CODEQP"})
  nGetDesEqp := aScan(aHeadGET, {| aVet | aVet[2] == "GET_DESEQP"})
  nGetDatAge := aScan(aHeadGET, {| aVet | aVet[2] == "GET_DATAGE"})
  nGetHorAge := aScan(aHeadGET, {| aVet | aVet[2] == "GET_HORAGE"})
  nGetDatFin := aScan(aHeadGET, {| aVet | aVet[2] == "GET_DATFIN"})
  nGetHoraFi := aScan(aHeadGET, {| aVet | aVet[2] == "GET_HORAFI"})
  
  If Empty(aColsGET[1, nGetIteAge])
   aColsGET[1, nGetIteAge] := StrZero(1, Len(GET->GET_ITEAGE))
  EndIf 
 
  HS_BDados("GMR", @aHeadGMR, @aColsGMR,, 1,, IIF(!Empty(M->GMJ_CODAGE), "GMR->GMR_CODAGE == '" + M->GMJ_CODAGE + "'", Nil))
 
  nGmrItem   := aScan(aHeadGMR, {| aVet | aVet[2] == "GMR_ITEM  "})
  nGmrCodGrp	:= aScan(aHeadGMR, {| aVet | aVet[2] == "GMR_CODGRP"}) 
                                                         
  If Empty(aColsGMR[1, nGebItem])
   aColsGMR[1, nGmrItem] := StrZero(1, Len(GMR->GMR_ITEM))
  EndIf 
 Else 
  HS_BDados("GMJ", @aHeadTrab, @aColsTrab,, 8,,)
 
  aColsTrab :={}

  AADD(aColsTrab, Array(Len(aHeadTrab) + 1))
  aColsTrab[Len(aColsTrab), Len(aHeadTrab) + 1] := .F.
  
 EndIf
               
 aSize := MsAdvSize()
 
 aObjs := {{100, 050, .T., .T.}, ;
           {100, 050, .T., .T., .T.}}
 
 aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
 aPObj := MsObjSize(aInfo, aObjs, .T.)                     
  
 aObjs := {{065, 100, .T., .T.}, ;
           {035, 100, .T., .T., .T.}}

 aInfo := {aPObj[1, 2], aPObj[1, 1], aPObj[1, 4], aPObj[1, 3], 0, 0}
 aPEnc := MsObjSize(aInfo, aObjs, .T., .T.)
  
 aObjs := {{100, 050, .T., .T.}, ;
           {100, 050, .T., .T.}}

 aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
 aPAux := MsObjSize(aInfo, aObjs, .T.)  
 
 aObjs := {{033, 100, .T., .T., .T.}, ;
           {033, 100, .T., .T., .T.}, ;	
           {033, 100, .T., .T., .T.}}

 aInfo := {aPAux[2, 2], 0, aPAux[2, 4], aPAux[2, 3] - aPAux[2, 1], 0, 0}
 aPMem := MsObjSize(aInfo, aObjs, .T., .T.)
 
 aObjs := {{100, 100, .T., .T.}}

 aInfo := {aPAux[2, 2], 0, aPAux[2, 4], aPAux[2, 3] - aPAux[2, 1], 0, 0}
 aPGet := MsObjSize(aInfo, aObjs, .T., .F.)
 
 DEFINE MSDIALOG oDlgAgd TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL
  If !lRemaneja
   aCposUsu := HS_CposUsu(@aCpoAlt, "GMJ")        
   oEncGmj := MsMGet():New(cAliasM39, nRegM39, nOpcM39,,,, aCpoEnc, aPEnc[1], aCpoAlt, 3,,,, oDlgAgd,, .T.,,,,,, .T.)
   oEncGmj:oBox:Align := CONTROL_ALIGN_ALLCLIENT
  Else
   oGetTrab := MsNewGetDados():New(aPEnc[1, 1], aPEnc[1, 2], aPEnc[1, 3], aPEnc[1, 4], 0,,,,,,,,,, oDlgAgd, aHeadTrab, aColsTrab)
   oGetTrab:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  EndIf

  oFolder := TFolder():New(aPObj[2, 1], aPObj[2, 2], aTitulos, aPaginas, oDlgAgd,,,, .T., .F., aPObj[2, 3], aPObj[2, 4])			
  oFolder:Align := CONTROL_ALIGN_BOTTOM
  
  // Disponibilidade
  oGetGMJ := MsNewGetDados():New(aPGet[1, 1], aPGet[1, 2], aPGet[1, 3], aPGet[1, 4], 0,,,,,,,,,, oFolder:aDialogs[01], aHeadGMJ, aColsGMJ)
  oGetGMJ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGetGMJ:oBrowse:BlDblClick := {|| IIF(StrZero(nOpcM39, 2) $ "03/05" .And. !lPreInt, Nil, FS_SALESCO(@aAgeMar, @aAgeLock, nOpcM39))}
  
  If !lRemaneja
  oAgdDia := MsNewGetDados():New(aPGet[1, 1], aPGet[1, 2], aPGet[1, 3], aPGet[1, 4], 0,,,,,,,,,, oFolder:aDialogs[02], aHAgdDia, aCAgdDia)
  oAgdDia:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  EndIf
  
  oPanCal	:=	tPanel():New(aPEnc[2, 1], aPEnc[2, 2],, oDlgAgd,,,,,, aPEnc[2, 3], aPEnc[2, 4])
  oPanCal:Align := CONTROL_ALIGN_RIGHT
   
  oCalSala := MsCalend():New(02, 02, oPanCal)
  oCalSala:ALIGN      := CONTROL_ALIGN_ALLCLIENT
  oCalSala:dDiaAtu    := IIF(nOpcM39 == 2 .Or. lRemaneja, dDataBase, M->GMJ_DATAGE) // 2-Agendar
  oCalSala:bChangeMes := {|| IIF ((nOpcM39 != 4 .And. !lRemaneja), {FS_MontEst(@oGetTrf:aCols, @oGetTrf:aHeader), oGetTrf:oBrowse:Refresh()}, .T.),;
                             FS_MudaMes(M->GMJ_CODCRM, M->GMJ_CODPLA, M->GMJ_CODPRO, IIf(!lRemaneja, oGetGEA:aCols, Nil), Nil), ;
                             FS_BrwSalas(M->GMJ_CODPRO, M->GMJ_CODCRM, M->GMJ_CODPLA, IIf(!lRemaneja, oGetGEA:aCols, Nil), Nil),;
                             IIF(!lRemaneja,Eval({|| FS_MntAgd(@oAgdDia:aHeader,@oAgdDia:aCols,@nUsuAgdDia,oCalSala:dDiaAtu),oAgdDia:oBrowse:Refresh(),.T.}),.T.) }
  oCalSala:bChange    := {|| IIF ((nOpcM39 != 4 .And. !lRemaneja), {FS_MontEst(@oGetTrf:aCols, @oGetTrf:aHeader), oGetTrf:oBrowse:Refresh()}, .T.),;
                              FS_BrwSalas(M->GMJ_CODPRO, M->GMJ_CODCRM, M->GMJ_CODPLA, IIf(!lRemaneja, oGetGEA:aCols, Nil), Nil),;
                              IIF(!lRemaneja,Eval({|| FS_MntAgd(@oAgdDia:aHeader,@oAgdDia:aCols,@nUsuAgdDia,oCalSala:dDiaAtu),oAgdDia:oBrowse:Refresh(),.T.}),.T.) }

  If StrZero(nOpcM39, 2) $ "03/05" .Or. lPreInt
   oCalSala:Disable()
  EndIf                                                           
  
  // Horarios a transferir 
  If nOpcM39 == 4
   oGetTrf := MsNewGetDados():New(080, 02, 150, 170, 0,,,,,,,,,, oPanCal, aHeadTrf, aColsTrf)
   oGetTrf:oBrowse:Align := CONTROL_ALIGN_BOTTOM
  ElseIf !lRemaneja 
   FS_MontEst(@aColsTrf, @aHeadTrf)
   oGetTrf := MsNewGetDados():New(080, 02, 150, 170, 0,,,,,,,,,, oPanCal, aHeadTrf, aColsTrf)
   oGetTrf:oBrowse:Align := CONTROL_ALIGN_BOTTOM
  EndIf
                                                  
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Edicao das Observacoes: Plano/Procedimento/Profissional		    ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  If !lRemaneja
   oPanPla	:=	tPanel():New(aPMem[1, 1], aPMem[1, 2], STR0028, oFolder:aDialogs[03], oFont, .F.,,,, aPMem[1, 3], aPMem[1, 4], .T., .T.) //"Plano"
   oPanPla:Align := CONTROL_ALIGN_LEFT
  
   @ aPMem[1, 1] + 15, aPMem[1, 2] Get oObsPlano Var cObsPlano MEMO SIZE aPMem[1, 3], aPMem[1, 4]-25 Of oPanPla Pixel
   oObsPlano:lReadOnly := .T.
   oObsPlano:Align := CONTROL_ALIGN_BOTTOM

   oPanPro	:=	tPanel():New(aPMem[2, 1], aPMem[2, 2], STR0029, oFolder:aDialogs[03], oFont, .F.,,,, aPMem[2, 3], aPMem[2, 4], .T., .T.) //"Procedimento"
   oPanPro:Align := CONTROL_ALIGN_ALLCLIENT
  
   @ aPMem[1, 1]+15, aPMem[1, 2] Get oObsProc Var cObsProc  MEMO SIZE aPMem[2, 3], aPMem[2, 4]-25 Of oPanPro Pixel      
   oObsProc:lReadOnly := .T.
   oObsProc:Align := CONTROL_ALIGN_BOTTOM

   oPanMed	:=	tPanel():New(aPMem[3, 1], aPMem[3, 2], STR0039, oFolder:aDialogs[03], oFont, .F.,,,, aPMem[3, 3], aPMem[3, 4], .T., .T.) //"Médico"
   oPanMed:Align := CONTROL_ALIGN_RIGHT 
  
   @ aPMem[1, 1] + 15, aPMem[1, 2] Get oObsProf Var cObsProf  MEMO SIZE aPMem[3, 3], aPMem[3, 4]-25 Of oPanMed Pixel 
   oObsProf:lReadOnly := .T.              
   oObsProf:Align := CONTROL_ALIGN_BOTTOM
                                                                        
   // Equipe médica
   oGetGE9 := MsNewGetDados():New(aPGet[1, 1], aPGet[1, 2], aPGet[1, 3], aPGet[1, 4], IIF(!lPreInt, nGDOpc, Nil),,, "+GE9_ITEM",,,,,,, oFolder:aDialogs[4], aHeadGE9, aColsGE9)
   oGetGE9:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oGetGE9:oBrowse:bGotFocus  :={ || cTmpCodEsp := cGbjCodEsp, cGbjCodEsp := Space(Len(GBJ->GBJ_ESPEC1)) }
   oGetGE9:oBrowse:bLostFocus :={ || cGbjCodEsp := cTmpCodEsp }
   oGetGE9:bLinhaOk := {|| HS_DuplAC(oGetGE9:oBrowse:nAt, oGetGE9:aCols, {nGe9CodCrm})}
  
   // Procedimentos especiais
   oGetGEA := MsNewGetDados():New(aPGet[1, 1], aPGet[1, 2], aPGet[1, 3], aPGet[1, 4], nGDOpc,,,"+GEA_ITEM",,,,,,, oFolder:aDialogs[5], aHeadGEA, aColsGEA)
   oGetGEA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oGetGEA:bLinhaOk := {|| HS_DuplAC(oGetGEA:oBrowse:nAt, oGetGEA:aCols, {nGeaCodPro})}
   oGetGEA:cFieldOk := "HS_BEqpAge('Vld')"
   oGetGEA:oBrowse:bdelete  := {|| oGetGEA:DelLine(), HS_BEqpAge(), FS_MudaMes(M->GMJ_CODCRM, M->GMJ_CODPLA, M->GMJ_CODPRO, IIf(!lRemaneja, oGetGEA:aCols, Nil), Nil), ;
                                    FS_BrwSalas(M->GMJ_CODPRO, M->GMJ_CODCRM, M->GMJ_CODPLA, IIf(!lRemaneja, oGetGEA:aCols, Nil), Nil)}
   
   // Materiais especiais
   oGetGEB := MsNewGetDados():New(aPGet[1, 1], aPGet[1, 2], aPGet[1, 3], aPGet[1, 4], nGDOpc,,,"+GEB_ITEM",,,,,,, oFolder:aDialogs[6], aHeadGEB, aColsGEB)
   oGetGEB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oGetGEB:bLinhaOk := {|| HS_DuplAC(oGetGEB:oBrowse:nAt, oGetGEB:aCols, {nGebCodMat})}
  
   // Equipamentos
   oGetGET := MsNewGetDados():New(aPGet[1, 1], aPGet[1, 2], aPGet[1, 3], aPGet[1, 4], IIF(StrZero(nOpcM39,2) $ "02/05", nGDOpc, 0),,,"+GET_ITEAGE",,,,,,, oFolder:aDialogs[7], aHeadGET, aColsGET)
   oGetGET:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                                      
   oGetGET:oBrowse:bdelete  := {|| Iif(FS_DelGET(nOpcM39), oGetGET:DelLine(), .F.)}
   
   // Equipamentos do Medico
   oGetGMR := MsNewGetDados():New(aPGet[1, 1], aPGet[1, 2], aPGet[1, 3], aPGet[1, 4], IIF(!lPreInt, nGDOpc, Nil),,, "+GMR_ITEM",,,,,,, oFolder:aDialogs[8], aHeadGMR, aColsGMR)
   oGetGMR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oGetGMR:bLinhaOk := {|| HS_DuplAC(oGetGMR:oBrowse:nAt, oGetGMR:aCols, {nGmrCodGrp})}
   oGetGMR:oBrowse:bdelete  := {|| oGetGMR:DelLine(),;
                                    FS_BrwSalas(M->GMJ_CODPRO, M->GMJ_CODCRM, M->GMJ_CODPLA, IIf(!lRemaneja, oGetGEA:aCols, Nil), Nil)}
   oGetGMR:oBrowse:beditcol := {|| FS_BrwSalas(M->GMJ_CODPRO, M->GMJ_CODCRM, M->GMJ_CODPLA, IIf(!lRemaneja, oGetGEA:aCols, Nil), Nil)}
   
  EndIf
  
  If nOpcM39 <> 2 
   FS_MudaMes(M->GMJ_CODCRM, M->GMJ_CODPLA, M->GMJ_CODPRO, IIf(!lRemaneja, oGetGEA:aCols, Nil), Nil)
   FS_BrwSalas(M->GMJ_CODPRO, M->GMJ_CODCRM, M->GMJ_CODPLA, IIf(!lRemaneja, oGetGEA:aCols, Nil), Nil)
  EndIf 
  
  oDlgAgd:bStart := { || FS_IniObs(), IIF(lPreInt, {FS_IniPrIn(),oEncGMJ:Refresh()}, Nil)} 
           
 ACTIVATE MSDIALOG oDlgAgd ON INIT EnchoiceBar(oDlgAgd, {|| nOpcAgd := 1, IIF(Obrigatorio(aGets, aTela) .And. IIF(nOpcM39 == 2, HS_BEqpAge("Ok"), HS_M39VTrf(nOpcM39, aAgeMar)) .and. FS_TudoOK(nOpcM39,GMJ->GMJ_CODAGE,@oGetGEB:aCols,oGetGEB:oBrowse:Refresh()) , oDlgAgd:End(), nOpcAgd := 0)}, ;
                                                        {|| oDlgAgd:End(), nOpcAgd := 0},, aButtons)
                                                                                                              
 If nOpcAgd == 1 .And. !lRemaneja
 
  Begin Transaction
   // Grava agenda cirurgica
   FS_GrvM39(nOpcM39, oGetGe9, oGetGea, oGetGeb, oGetGet)
   
  End Transaction
  
  While __lSx8
   ConfirmSx8()
  End  
  
 Else
  
  FS_M39Canc(aAgeLock)
  
  While __lSx8
   RollBackSxe()
  End
  
 EndIf
 
 If nOpcM39 == 2 .And. nOpcAgd == 1 
  Hs_RelM39()
 EndIf
 
Return(NIL)                        

Static Function FS_M39Canc(aAgeLock)

Local nMarcAnt := 0
 
For nMarcAnt := 1 To Len(aAgeLock)
	UnLockByName("M39GMJ" + aAgeLock[nMarcAnt], .T., .T., .F.)
Next

Return()



Static Function FS_GrvM39(nOpcM39, oGetGe9, oGetGea, oGetGeb, oGetGet)

Local nForAge := 0, cStatus := "", cSeqAge := "", aArea := GetArea(), aAreaGMJ := {}
Local dDataIn := CToD(""), cHoraIn := "", dDataFi := CToD(""), cHoraFi := "" 
Local nGmjCrm :=0, nGmjTempro:=0, lFlagMed:=.F.
Local nCont   := 0
 
Private aCFound := {}

If nOpcM39 == 4 .Or. lRemaneja

  If !lRemaneja
   nGmjCrm := aScan(oGetTrf:aHeader, {| aVet | aVet[2] == "GMJ_CODCRM"})          
  
   //faz a a verificacao se e o mesmo medico.....    
   If oGetTrf:aCols[1][nGmjCrm] <> M->GMJ_CODCRM // Se modificou o médico... irá gravar no GE9
    lFlagMed:=.T.
   EndIf
  Else
   nGmjCrm  := aScan(oGetTrab:aHeader, {| aVet | aVet[2] == "GMJ_CODCRM"})
   aAreaAux := GetArea()
    DbSelectArea("GMJ")
    DbSetOrder(1) // GMJ_FILIAL + GMJ_CODAGE
    DbSeek(xFilial("GMJ") + aAgeTrfCan[1])
    RegToMemory("GMJ", .F.)
   RestArea(aAreaAux)
  EndIf
 
  //Equipe médica
  FS_GrTrM39("GE9", 1, aAgeGrv[1], aAgeTrfCan[1], IIF(lRemaneja, oGetTrab:aCols[1][nGmjCrm], oGetTrf:aCols[1][nGmjCrm])) 
  
  // Procedimentos especiais
  FS_GrTrM39("GEA", 1, aAgeGrv[1], aAgeTrfCan[1], IIF(lRemaneja, oGetTrab:aCols[1][nGmjCrm], oGetTrf:aCols[1][nGmjCrm])) 
  
  // Materiais especiais
  FS_GrTrM39("GEB", 1, aAgeGrv[1], aAgeTrfCan[1], IIF(lRemaneja, oGetTrab:aCols[1][nGmjCrm], oGetTrf:aCols[1][nGmjCrm])) 
  
  aAreaGMJ := GetArea()
  DbSelectArea("GMJ")
  DbSetOrder(1) //GMJ_FILIAL + GMJ_CODAGE
  DbSeek(xFilial("GMJ") + aAgeGrv[1]) // Posiciona no ultimo horario selecionado da agenda.
  dDataFi := GMJ->GMJ_DATAGE
  dDataIn := GMJ->GMJ_DATAGE
  cHoraIn := GMJ->GMJ_HORAGE
  cHoraFi := HS_TotHoras(cHoraIn, HS_IniPadr("GMJ", 1, aAgeTrfCan[1], "GMJ_TEMPRO",, .F.))
  RestArea(aAreaGMJ)
   
  // Equipamentos
  FS_GrTrM39("GET", 1, aAgeGrv[1], aAgeTrfCan[1], IIF(lRemaneja, oGetTrab:aCols[1][nGmjCrm], oGetTrf:aCols[1][nGmjCrm]), dDataIn, cHoraIn, dDataFi, cHoraFi) 
  
  // Equipamentos do Medico
  FS_GrTrM39("GMR", 1, aAgeGrv[1], aAgeTrfCan[1], IIF(lRemaneja, oGetTrab:aCols[1][nGmjCrm], oGetTrf:aCols[1][nGmjCrm])) 
 EndIf
 
 If StrZero(nOpcM39, 2) $ "03/04" .Or. lRemaneja //Cancelamento/Transferencia/Remanejamento
  If HS_IniPadr("GM7", 1, M->GMJ_MOTIVO, "GM7_IDEBLO",, .F.) == "2" //Libera
   cStatus := "2"
  Else           
   cStatus := "0"
  EndIf
  
  If nOpcM39 == 3
   // Limpa tudo.....
   FS_LogLimp(cStatus, aAgeTrfCan, "GML") //Grava log , limpa os dados e altera o status do horario

   //Equipe médica
   FS_LimpCan("GE9", 1, aAgeTrfCan[1]) // Limpa....
   
   // Procedimentos especiais
   FS_LimpCan("GEA", 1, aAgeTrfCan[1]) // Limpa....
   
   // Materiais especiais
   FS_LimpCan("GEB", 1, aAgeTrfCan[1]) // Limpa....
   
   // Equipamentos
   FS_LimpCan("GET", 1, aAgeTrfCan[1]) // Limpa.... 
   
   // Equipamentos do Medico
   FS_LimpCan("GMR", 1, aAgeTrfCan[1]) // Limpa.... 
      
  Else 
   FS_LogLimp(cStatus, aAgeTrfCan, "GMM") //Grava log , limpa os dados e altera o status do horario
  EndIf
  
 EndIf
 
 If nOpcM39 <> 3
  
  DbSelectArea("GMJ")
  DbSetOrder(1) //GMJ_FILIAL + GMJ_CODAGE
  DbSeek(xFilial("GMJ") + aAgeGrv[Len(aAgeGrv)]) // Posiciona no ultimo horario selecionado da agenda.
  dDataFi := GMJ->GMJ_DATAGE
                       
  For nForAge := 1 To Len(aAgeGrv)
  
   DbSeek(xFilial("GMJ") + aAgeGrv[nForAge])
   cStatus := IIF(StrZero(nOpcM39, 2) $ "02/04" .Or. lRemaneja, "1", GMJ->GMJ_STATUS)                        
   cSeqAge := IIF(nForAge == 1, GMJ->GMJ_CODAGE, cSeqAge)
   dDataIn := IIF(nForAge == 1, GMJ->GMJ_DATAGE, dDataIn)
   cHoraIn := IIF(nForAge == 1, GMJ->GMJ_HORAGE, cHoraIn)
   cHoraFi := IIF(nForAge == 1, HS_TotHoras(GMJ->GMJ_HORAGE, M->GMJ_TEMPRO), cHoraFi)
  
   RecLock("GMJ", .F.)
    GMJ->GMJ_HORAFI := cHoraFi
    GMJ->GMJ_REGGER := M->GMJ_REGGER
    GMJ->GMJ_NOMPAC := M->GMJ_NOMPAC
    GMJ->GMJ_MATRIC := M->GMJ_MATRIC
    GMJ->GMJ_TELPAC := M->GMJ_TELPAC
    GMJ->GMJ_CODPLA := M->GMJ_CODPLA
    GMJ->GMJ_SQCATP := M->GMJ_SQCATP
    GMJ->GMJ_CODPRO := M->GMJ_CODPRO
    GMJ->GMJ_CODCRM := M->GMJ_CODCRM
    GMJ->GMJ_STATUS := cStatus
    GMJ->GMJ_CODCON := HS_IniPadr("GCM", 2, M->GMJ_CODPLA, "GCM_CODCON",, .F.)
    GMJ->GMJ_USAUTI := M->GMJ_USAUTI
    GMJ->GMJ_HEMODE := M->GMJ_HEMODE
    GMJ->GMJ_TOPOGR := M->GMJ_TOPOGR
    GMJ->GMJ_TEMPRO := M->GMJ_TEMPRO
    GMJ->GMJ_CODPAT := M->GMJ_CODPAT
    GMJ->GMJ_DIAGNO := M->GMJ_DIAGNO    
    GMJ->GMJ_DATINT := M->GMJ_DATINT
    GMJ->GMJ_OBSERV := M->GMJ_OBSERV
    GMJ->GMJ_SEQAGE := cSeqAge
    GMJ->GMJ_IDADE  := M->GMJ_IDADE
    GMJ->GMJ_PESO   := M->GMJ_PESO
    If nOpcM39 == 2 .Or. nOpcM39 == 4
     GMJ->GMJ_DATCAD := dDatabase
     GMJ->GMJ_HORCAD := Time()
     GMJ->GMJ_CODUSU := cUserName
    EndIf
    If GMJ->(FieldPos("GMJ_USAEQP")) > 0     
     GMJ->GMJ_USAEQP := M->GMJ_USAEQP
    EndIf
    If lPreInt
     GMJ->GMJ_NRGUIA := M->GMJ_NRGUIA
     GMJ->GMJ_NRSEN1 := M->GMJ_NRSEN1
     GMJ->GMJ_NRSEN2 := M->GMJ_NRSEN2
     GMJ->GMJ_NRSEN3 := M->GMJ_NRSEN3
     GMJ->GMJ_QTDIAS := M->GMJ_QTDIAS 
     If HS_ExisDic({{"C", "GMJ_INDCLI"}},.F.)
     	GMJ->GMJ_INDCLI := M->GMJ_INDCLI
     EndIf
     GMJ->GMJ_LOGPIN := HS_LogArq()
    EndIf
    GMJ->GMJ_LOGARQ := HS_LogArq()
    For nCont:= 1 To Len(aCposUsu)
     If ValType("M->" + aCposUsu[nCont]) != "U"
      GMJ->&(aCposUsu[nCont]) := M->&(aCposUsu[nCont])
     EndIf
    Next
   MsUnLock()
  
   UnLockByName("M39GMJ" + aAgeGrv[nForAge], .T., .T., .F.)
  
  Next 
 EndIf
 
 If lFlagMed .Or. StrZero(nOpcM39, 2) $ "02/05" 
  // Grava equipe médica
  FS_GrvGD("GE9", 1, oGetGe9:aHeader, oGetGe9:aCols, cSeqAge, nGe9Item, nGe9CodCrm)
 EndIf
  
 If StrZero(nOpcM39, 2) $ "02/05" .Or. lPreInt
  // Procedimentos especiais
  FS_GrvGD("GEA", 1, oGetGea:aHeader, oGetGea:aCols, cSeqAge, nGeaItem, nGeaCodPro)
   
  // Materiais especiais
  FS_GrvGD("GEB", 1, oGetGeb:aHeader, oGetGeb:aCols, cSeqAge, nGebItem, nGebCodMat)
  
  // Equipamentos
  FS_GrvGD("GET", 1, oGetGet:aHeader, oGetGet:aCols, cSeqAge, nGetIteAge, nGetCodEqp, dDataIn, cHoraIn, dDataFi, cHoraFi)
  
  // Equipamentos do Medico
  FS_GrvGD("GMR", 1, oGetGmr:aHeader, oGetGmr:aCols, cSeqAge, nGmrItem, nGmrCodGrp)
  
 EndIf

If HS_ExisDic({{"T", "GNX"}},.F.)               
	FS_GrvSol(cSeqAge,oGetGea,oGetGeb,nGeaItem,nGebItem,nOpcM39) 
EndIf

 RestArea(aArea)         
 
 //Refresh no Browse
 DbSelectArea("GMJ")
 If nOpcM39 == 3
  DbGotop()
 Else
  DbSetOrder(1) // GMJ_FILIAL + GMJ_CODAGE
  DbSeek(xFilial("GMJ") + aAgeGrv[1])
 EndIf

Return(cSeqAge)

//Gravacao da solictacao de autorizacao e itens da solicitacao
//Function HS_GRVGNX(cRegGer,cNomPac,cCodUsu,cCodAge,cRegAte,cCarInt,cTipInt,cRegInt,cDiaSol,cIndCli,dDtpAdm,dDatAdm,aHProc,aCProc,aHMat,aCMat)
Static Function FS_GrvSol(cSeqAge,oGetGea,oGetGeb,nGeaIt, nGebIt, nOpcM39)
Local i,j        	:= 0
Local nPos,nPosP 	:= 0
Local aHProc		:= {{"","GE3_FILIAL"},{"","GE3_DATSOL"},{"","GE3_HORSOL"},{"","GE3_QTDSOL"},{"","GE3_CODDES"},{"","GE3_CODPRT"},;
																	{"","GE3_SEQDES"},{"","GE3_LOGARQ"},{"","GE3_STATUS"}}
Local aCProc		:= {}
Local aHMat   		:= {{"","GE2_FILIAL"},{"","GE2_DATSOL"},{"","GE2_HORSOL"},{"","GE2_QTDSOL"},{"","GE2_CODDES"},{"","GE2_CODPRT"},;
																 {"","GE2_SEQDES"},{"","GE2_LOGARQ"},{"","GE2_STATUS"}}
Local aCMat   		:= {}
Local aGe	    	:= {{oGetGea:aCols,oGetGea:aHeader,aCProc,"GE3","GEA_CODPRO","GD7","4",nGeaIt},{oGetGeb:aCols,oGetGeb:aHeader,aCMat,"GE2","GEB_CODMAT","GD5","3",nGebIt}}
                                                                                        

If (lAut := Hs_DespAut("GD7", M->GMJ_CODPLA, M->GMJ_CODPRO, , "4")) .AND. nOpcM39 == 2   // Verifica se o item necessita de autorizacao
	If MsgYesNo("Procedimento [" + M->GMJ_CODPRO + "] requer autorização, Deseja envia-lo para o Controle de Solicitações? ") //"Procedimento requer autorização, Deseja envia-lo para o Controle de Solicitações? "
		If !HS_ExisDic({{"T", "GNX"}},.F.)
			HS_MsgInf("Para utilizar essa rotina execute o atualizador GH147276 (Controle de Autorizações). Consulte suporte para mais detalhes", "Atencao", "Validacao Dicionarios") //"Para utilizar essa rotina execute o atualizador GH147276 (Controle de Autorizações). Consulte suporte para mais detalhes", "Atencao", "Validacao Dicionarios"
		Else
			AADD(aGe[1,3],{xFilial(aGe[1,4]),dDataBase,Time(),1,M->GMJ_CODPRO,,GetSXEnum(aGe[1,4],aGe[1,4]+"_SEQDES",, 1),HS_LogArq(),"0"}) //procedimento principal
		EndIf
	EndIf
EndIf
For i := 1 to Len(aGe)
	For j := 1 to Len (aGe[i,1])
		nPos  := ASCAN(aGe[i,2],{|aVet| aVet[2] == aGe[i,5]})
		nPosP := ASCAN(aCFound,{|aVet| aVet[1] == Substring(aGe[i,5],1,3) + aGe[i,1][j,aGe[i,8]]})		//  GEA001/GEB001 Verifica se o item já foi inserido
		If nPos >0 .AND. nPosP >0
		 	If (lAut := Hs_DespAut(aGe[i,6], M->GMJ_CODPLA, aGe[i,1][j, nPos], , aGe[i,7])) .AND. !aGe[i,1][j, Len(aGe[i,2])+1]    // Verifica se o item necessita de autorizacao e se não está deletado
		 		If MsgYesNo("Procedimento [" + aGe[i,1][j, nPos] + "] requer autorização, Deseja envia-lo para o Controle de Solicitações? ") //"Procedimento requer autorização, Deseja envia-lo para o Controle de Solicitações? "
					If !HS_ExisDic({{"T", "GNX"}},.F.)
						HS_MsgInf("Para utilizar essa rotina execute o atualizador GH147276 (Controle de Autorizações). Consulte suporte para mais detalhes", "Atencao", "Validacao Dicionarios") //"Para utilizar essa rotina execute o atualizador GH147276 (Controle de Autorizações). Consulte suporte para mais detalhes", "Atencao", "Validacao Dicionarios"
					Else
						If aGe[i,4]<>"GE2"
			   			AADD(aGe[i,3],{xFilial(aGe[i,4]),dDataBase,Time(),IIf(M->GMJ_CODPRO == aGe[i,1][j, nPos],2,1),aGe[i,1][j, nPos],,GetSXEnum(aGe[i,4],aGe[i,4]+"_SEQDES",, 1),HS_LogArq(),"0"})
			   			Else 
			   				AADD(aGe[i,3],{xFilial(aGe[i,4]),dDataBase,Time(),aGe[i,1][j, 4],aGe[i,1][j, nPos],,GetSXEnum(aGe[i,4],aGe[i,4]+"_SEQDES",, 1),HS_LogArq(),"0"})			   				
     			   		   	aCmat[j,4]:=aGe[i,1][j, 4]
     			   		Endif   	        		
			  		EndIf
			  	EndIf
			EndIf
		Endif
	Next j
Next i      

//Function HS_GRVGNX(cRegGer,cNomPac,cCodUsu,cCodAge,cRegAte,cCarInt,cTipInt,cRegInt,cDiaSol,cIndCli,dDtpAdm,dDatAdm,aHProc,aCProc,aHMat,aCMat)
HS_GRVGNX(M->GMJ_REGGER,M->GMJ_NOMPAC,Substring(cUsuario,7,15),cSeqAge,,M->GMJ_CODPLA,"E","2","1",M->GMJ_QTDIAS,M->GMJ_INDCLI,,,aHProc,aCProc,aHMat,aCmat)

Return(Nil)

Static Function FS_GrvGD(cAlias, nOrdem, aHGrv, aCGrv, cSeqAge, nGDSeek, nGDEmpty, dDataIn, cHoraIn, dDataFi, cHoraFi)

 Local nFGrv := 0, lFound := .F.
 Local cPGrv :=  cAlias + "->" + PrefixoCpo(cAlias)
 Local nUGrv := Len(aHGrv) + 1  
 Local aArea := GetArea()
 Local cTempoA := ""
 Local aCpoIni:= {}, aCpoFim := {}
 
 For nFGrv := 1 To Len(aCGrv)
  
  If !Empty(aCGrv[nFGrv, nGDEmpty])
  
   DbSelectArea(cAlias)
   DbSetOrder(nOrdem)
   lFound := DbSeek(xFilial(cAlias) + cSeqAge + aCGrv[nFGrv, nGdSeek])
                         
   If !lFound
   		AADD(aCFound , {cAlias + aCGrv[nFGrv, nGdSeek]})
   EndIf		
   If !aCGrv[nFGrv, nUGrv]
   
    RecLock(cAlias, !lFound)
     HS_GRVCPO(cAlias, aCGrv, aHGrv, nFGrv)
     &(cPGrv + "_FILIAL") := xFilial(cAlias)
     &(cPGrv + "_CODAGE") := cSeqAge
     &(cPGrv + "_LOGARQ") := HS_LogArq()
     
     If cAlias == "GET"
      cTempoA := HS_IniPadr("GF9", 1, aCGrv[nFGrv, nGetCodGrp], "GF9_TEMPOA",, .F.)
      
      aCpoIni := HS_CALCDAT(dDataIn, cHoraIn, "-", cTempoA)
      aCpoFim := HS_CALCDAT(dDataIn, cHoraFi, "+", cTempoA)
            
      GET->GET_DATAGE := aCpoIni[1] 
      GET->GET_HORAGE := aCpoIni[2] 
      GET->GET_DATFIN := aCpoFim[1]
      GET->GET_HORAFI := aCpoFim[2]
     EndIf
    MsUnlock()
   Else   
    If lFound
     RecLock(cAlias, .F., .F.)
      DbDelete()
     MsUnLock() 
     WriteSx2(cAlias)
    EndIf 
   EndIf   
  Endif 
 Next 
 
 RestArea(aArea)
Return(Nil)          


Static Function FS_GrTrM39(cAlias, nOrdem, cCodAgeAtu, cCodAgeAnt, cCodCrmAnt, dDataIn, cHoraIn, dDataFi, cHoraFi)

 Local aArea := GetArea()
 Local cPGrv :=  cAlias + "->" + PrefixoCpo(cAlias)
	Local aCpoIni := {}, aCpoFim := {} 
	Local nPos    := 0, nIteAge  := nGetIteAge
	Local nUsadGET := 0//Len(oGetGET:aHeader) + 1
	Local aHeadGET := {}, aColsGET := {}											
																																							
 If cAlias == "GE9" //Atualiza os campos da GE9
  DbSelectArea(cAlias)
  DbSetOrder(nOrdem)
  While DbSeek(xFilial(cAlias) + aAgeTrfCan[1])
   RecLock(cAlias, .F.)
    If M->GMJ_CODCRM == cCodCrmAnt // Nao modificou o medico durante a transferencia....
     &(cPGrv + "_CODAGE"):= cCodAgeAtu
    Else // Se ele mudou o medico.. apaga os registros do GE9
     DbDelete()
    EndIf
   MsUnlock() 
  End
 Else
  DbSelectArea(cAlias)
  DbSetOrder(nOrdem)
  While DbSeek(xFilial(cAlias) + aAgeTrfCan[1])
   RecLock(cAlias, .F.)
    &(cPGrv + "_CODAGE") := cCodAgeAtu
    If cAlias == "GET"
      
      If oGetGet # Nil //Necessaria validação da existencia por causa da "Realocação"
       aHeadGET := oGetGet:aHeader
       aColsGET := oGetGet:aCols											
      Else
       aHeadGET := {}
       aColsGET := {}
       HS_BDados("GET", @aHeadGET, @aColsGET,, 1,,"GET->GET_CODAGE == '" + M->cCodAgeAnt + "'")      
      Endif
       
      nUsadGET := Len(aHeadGET) + 1 
         
      nIteAge := IIF(nIteAge == 0,aScan(aHeadGET, {| aVet | aVet[2] == "GET_ITEAGE"}), nIteAge)
      
      nPos := aScan(aColsGet, {| aVet | aVet[nIteAge] == GET->GET_ITEAGE})
      
      If !lRemaneja .And. oGetGet:aCols[nPos][nUsadGET] // Deletado
       DBDelete()
      Else
       HS_GRVCPO("GET", aColsGet, aHeadGet, nPos)
    
       cTempoA := HS_IniPadr("GF9", 1, GET->GET_CODGRP, "GF9_TEMPOA",, .F.)      

       aCpoIni := HS_CALCDAT(dDataIn, cHoraIn, "-", cTempoA)     
       aCpoFim := HS_CALCDAT(dDataIn, cHoraFi, "+", cTempoA)
       
       GET->GET_DATAGE := aCpoIni[1] 
       GET->GET_HORAGE := aCpoIni[2] 
       GET->GET_DATFIN := aCpoFim[1]
       GET->GET_HORAFI := aCpoFim[2]
      EndIf 
    EndIf
   MsUnlock() 
   DbSkip()
  EndDo
 EndIf
 
 RestArea(aArea) 
 
Return()  


Static Function FS_LimpCan(cAlias, nOrdem, aCodAgeAnt) 
 
 Local aArea := GetArea()

 DbSelectArea(cAlias)
 DbSetOrder(nOrdem)
 While DbSeek(xFilial(cAlias) + aCodAgeAnt)
  RecLock(cAlias, .F.)
    DbDelete()
  MsUnlock() 
 EndDo
 
 RestArea(aArea)
 
Return()


Static Function FS_LogLimp(cStatus, aAgeTrfCan, cAliasLog)

 Local aArea := GetArea()
 Local nForAge, nField
 
 If cAliasLog == "GMM" .And. GMM->(FieldPos("GMM_SEQREG")) > 0
  M->GMM_SEQREG := HS_VSxeNum("GMM", "M->GMM_SEQREG", 4) 
  ConfirmSX8()  
      
 ElseIf cAliasLog == "GML" .And. GML->(FieldPos("GML_SEQREG")) > 0
  M->GML_SEQREG := HS_VSxeNum("GML", "M->GML_SEQREG", 4) 
  ConfirmSX8()  
 EndIf

 DbSelectArea("GMJ")
 DbSetOrder(1) //GMJ_FILIAL + GMJ_CODAGE  
 For nForAge := 1 To Len(aAgeTrfCan)
  If DbSeek(xFilial("GMJ") + aAgeTrfCan[nForAge])
   DbSelectArea(cAliasLog)

   RecLock(cAliasLog, .T.)
   For nField := 1 To FCount()             
   
    If SubStr(FieldName(nField), 4, 7) == "_FILIAL"                       
  
     FieldPut(FieldPos(FieldName(nField)), xFilial(cAliasLog))
  
    ElseIf SubStr(FieldName(nField), 4, 7) == "_LOGARQ"       
  
     FieldPut(FieldPos(FieldName(nField)), HS_LogArq())
  
    Else
    
     cCpoGmj := "GMJ" + SubStr(FieldName(nField), 4, 7)
    
     If GMJ->(FieldPos(cCpoGmj)) > 0
      FieldPut(FieldPos(FieldName(nField)), GMJ->(FieldGet(FieldPos(cCpoGmj))))
     EndIf 

    EndIf
   
   Next     
  
   If cAliasLog == "GMM"
    GMM->GMM_USUCAD := GMJ->GMJ_CODUSU 
    GMM->GMM_CODCAN := M->GMJ_MOTIVO
    GMM->GMM_DATCAN := dDataBase
 	  GMM->GMM_HORCAN := SubStr(Time(), 1, 5)
 	  GMM->GMM_USUCAN := cUserName
		  GMM->GMM_NOVAGE := aAgeGrv[1]
		  If GMM->(FieldPos("GMM_SEQREG")) > 0
		   GMM->GMM_SEQREG := M->GMM_SEQREG
		  EndIf
	  Else
	   GML->GML_USUCAD := GMJ->GMJ_CODUSU
    GML->GML_CODCAN := M->GMJ_MOTIVO
    GML->GML_DATCAN := dDataBase
    GML->GML_HORCAN := SubStr(Time(), 1, 5)
    GML->GML_USUCAN := cUserName
    If GML->(FieldPos("GML_SEQREG")) > 0
		   GML->GML_SEQREG := M->GML_SEQREG
    EndIf
   EndIf

   MsUnLock()
   
   RecLock("GMJ", .F.)
    GMJ->GMJ_STATUS := cStatus
    GMJ->GMJ_HORAFI := ""
    GMJ->GMJ_REGGER := ""
    GMJ->GMJ_NOMPAC := ""
    GMJ->GMJ_MATRIC := ""
    GMJ->GMJ_TELPAC := ""
    GMJ->GMJ_CODPLA := ""
    GMJ->GMJ_SQCATP := ""
    GMJ->GMJ_CODPRO := ""
    GMJ->GMJ_CODCRM := ""
    GMJ->GMJ_CODCON := ""
    GMJ->GMJ_CODUSU := ""
    GMJ->GMJ_USAUTI := ""
    GMJ->GMJ_HEMODE := ""
    GMJ->GMJ_TOPOGR := ""
    GMJ->GMJ_TEMPRO := ""
    GMJ->GMJ_CODPAT := ""
    GMJ->GMJ_DATINT := CToD("")
    GMJ->GMJ_ORICAN := ""
    GMJ->GMJ_MOTIVO := ""
    GMJ->GMJ_REGATE := ""
    GMJ->GMJ_SEQAGE := ""
    GMJ->GMJ_CRMPRI := ""
    GMJ->GMJ_IDADE  := ""
    GMJ->GMJ_PESO   := 0
    GMJ->GMJ_OK     := ""
    GMJ->GMJ_LOGARQ := HS_LogArq()
   MsUnlock()
  EndIf                                               
 Next
 
 RestArea(aArea)

Return() 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  	 ³HS_M38Leg ³ Autor ³  José Orfeu           ³ Data ³26/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas no Agendamento               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    		 ³ HSPAHM39                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M39Leg()

 Local aLegenda := {{"BR_VERMELHO", OemToAnsi(STR0026)}, ; //"Ocupado"
                    {"BR_AMARELO" , OemToAnsi(STR0030)}, ; //"Bloqueado"
                    {"BR_VERDE"   , OemToAnsi(STR0027)}, ; //"Livre"
                    {"BR_AZUL"    , OemToAnsi(STR0031)}}   //"Atendido"

 BrwLegenda(cCadastro, STR0032, aLegenda) //"Agendamento"
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_ConSala³ Autor ³ Robson Ramiro Oliveira³ Data ³ 29.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria uma consulta para sala e horario disponivel           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSP                                         													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ConSala(aHeadGMJ,nQtdHDis)

 Local nTamSet := 0, nCont := 0
 
 DbSelectArea("SX3")
 DbSetOrder(2) // X3_CAMPO
 DbSeek("GMJ_CODLOC")
 nTamSet	:= SX3->X3_TAMANHO
 
 DbSeek("GMJ_QUARTO")
 nTamSet += SX3->X3_TAMANHO + 05
 
 aAdd(aHeadGMJ,	{STR0070, STR0034, SX3->X3_PICTURE, nTamSet, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, "", SX3->X3_CONTEXT, SX3->X3_CBOX, "", ""}) //"SETOR/SALA"###"SALA"
 		                
 DbSeek("GMJ_HORAGE")
  
 For nCont := 1 To nQtdHDis
  aAdd(aHeadGMJ,	{"", STR0071 + StrZero(nCont, 3), "@BMP", 3, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, "", SX3->X3_CONTEXT, SX3->X3_CBOX, "", ""}) //"LEGENDA"
	 aAdd(aHeadGMJ,	{IIF(nCont == 1, STR0072, ""), "HORARIO" + StrZero(nCont, 3), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, "", SX3->X3_CONTEXT, SX3->X3_CBOX, "", ""}) //"HORARIOS"
 Next nCont		                

Return(.T.)         


Static Function FS_BrwSalas(cCodPro, cCodCrm, cCodPla, aCGea, nIGea,nQtdHDis)
 Local cQuery := "", nCols	:= 0, nCont	:= 0, cSala	:= "", nUsadGMJ := Len(oGetGmj:aHeader) + 1, aArea := GetArea()
 Local aCposGea := {}
 Local cCodCCu := ""
 // Para medir o desenpenho dessa rotina basta desabilitar as linhas com o marcador [DESEMP].
 //Local cHoraFin := ""
 Local cSqlEqp1 := "", cSqlEqp2 := "", cSqlEqp := "", cEqpPro := "", cGeaProc := "", cEqptoMed := "", nItens := 0
 Local cDataAtu := "", cDatHorI := "", cDatHorF := ""
 Local lDispOk := .F.
 
 Default aCGea := {}
 
 If oCalSala:dDiaAtu < dDataBase
  oCalSala:dDiaAtu := dDataBase
  oCalSala:Refresh()
 EndIf
 
 If (Empty(cCodPro) .Or. Empty(cCodCrm) .Or. Empty(cCodPla)) .And. !lRemaneja
  RestArea(aArea)
  Return(.T.)
 EndIf
  
 CursorWait()
 
 cDataAtu := oCalSala:dDiaAtu
                              
 If !lRemaneja
  cEqptoMed := HS_RetIn(@nItens, oGetGMR:aCols, Len(oGetGMR:aHeader), nGmrCodGrp)
 
  If nItens > 1
   cEqptoMed := HS_InSql(cEqptoMed, Len(GMR->GMR_CODGRP))
  ElseIf !Empty(cEqptoMed)
   cEqptoMed :="'" + cEqptoMed +"'"
  EndIf
 
  nItens := 0
 
  cGeaProc := HS_RetIn(@nItens, oGetGEA:aCols, Len(oGetGEA:aHeader), nGeaCodPro)
 
  If nItens > 1
   cGeaProc := HS_InSql(cGeaProc, Len(GFA->GFA_CODPRO))
  ElseIf !Empty(cGeaProc)
   cGeaProc := "'" + cGeaProc + "'"
  EndIf
 
  cEqpPro := IIF(!Empty(cGeaProc), cGeaProc + ",", "") + "'" + cCodPro + "'"
 
  cSqlEqp := "SELECT GFA.GFA_CODGRP, COUNT(GER.GER_CODEQP) NQTDGER, COUNT(ST9.T9_CODBEM) NQTDST9, COUNT(GET.GET_CODEQP) NQTDGET, COUNT(STJ.TJ_CODBEM) NQTDSTJ "
  cSqlEqp += "FROM " + RetSqlName("GFA") + " GFA "
  cSqlEqp +=      "JOIN " + RetSqlName("GER") + " GER ON (GER.GER_FILIAL = '" + xFilial("GER") + "' AND GER.D_E_L_E_T_ <> '*' AND GER.GER_CODGRP = GFA.GFA_CODGRP ) "
  cSqlEqp += "LEFT JOIN " + RetSqlName("ST9") + " ST9 ON (ST9.T9_FILIAL = '" + xFilial("ST9") + "' AND ST9.D_E_L_E_T_ <> '*' AND ST9.T9_CODBEM = GER.GER_CODEQP AND ST9.T9_SITBEM <> 'A' "
  If lEqpCCusto
   cSqlEqp += "AND ST9.T9_CCUSTO = '[cCodCCu]' "
  EndIf
  cSqlEqp += ") "
  cSqlEqp += "LEFT JOIN " + RetSqlName("STJ") + " STJ ON (STJ.TJ_FILIAL = '" + xFilial("STJ") + "' AND STJ.D_E_L_E_T_ <> '*' AND STJ.TJ_CODBEM = GER.GER_CODEQP AND STJ.TJ_SITUACA = 'P' AND STJ.TJ_TERMINO = 'N' AND STJ.TJ_TIPOOS = 'B') "
  cSqlEqp +=	"	AND (STJ.TJ_DTMPINI||STJ.TJ_HOMPINI < '[cDatHorF]' AND STJ.TJ_DTMPFIM||STJ.TJ_HOMPFIM > '[cDatHorI]') "
	 cSqlEqp += "LEFT JOIN " + RetSqlName("GET") + " GET ON (GET.GET_FILIAL = '" + xFilial("GET") + "' AND GET.D_E_L_E_T_ <> '*' AND GET.GET_CODGRP = GER.GER_CODGRP AND GET.GET_CODEQP = GER.GER_CODEQP AND GET.GET_CODAGE <>	'" + M->GMJ_CODAGE + "') "
	 cSqlEqp +=	"	AND (GET.GET_DATAGE||GET.GET_HORAGE < '[cDatHorF]' AND GET.GET_DATFIN||GET.GET_HORAFI > '[cDatHorI]') "
  cSqlEqp += "WHERE GFA.GFA_FILIAL = '" + xFilial("GFA") + "' AND GFA.D_E_L_E_T_ <> '*' AND GFA.GFA_CODPRO IN (" + cEqpPro + ") "
  If !Empty(AllTrim(cEqptoMed))
   cSqlEqp += " AND GFA.GFA_CODGRP NOT IN (" + cEqptoMed + ") "   //DESCONSIDERA EQUIPAMENTOS DO MEDICO
  EndIf

  cSqlEqp += "GROUP BY GFA.GFA_CODGRP "
  cSqlEqp += "HAVING (COUNT(GER.GER_CODEQP) = COUNT(ST9.T9_CODBEM)) OR (COUNT(GER.GER_CODEQP) = (COUNT(STJ.TJ_CODBEM) + COUNT(GET.GET_CODEQP))) "
 
  cSqlEqp := ChangeQuery(cSqlEqp)
 EndIf 
 
 M->GMJ_DATINT := cDataAtu // Luiz - 13/01/06
 
 oGetGmj:LACTIVE := .F. 
 oGetGmj:aCols := {}
 
 If nIGea <> Nil
  AADD(aCposGea, PADR(M->GEA_CODPRO, Len(GEA->GEA_CODPRO)))                       
 EndIf 
 For nCont := 1 To Len(aCGea)
  If !EMPTY(aCGea[nCont, nGeaCodPro]) .And. !aCGea[nCont, nUGEA + 1] .And. IIF(ValType("M->GEA_CODPRO") <> "U", nCont <> oGetGEA:oBrowse:nAt, .T.)
   AADD(aCposGea, PADR(aCGea[nCont, nGeaCodPro], Len(GEA->GEA_CODPRO)))                       
  EndIf 
 Next
 
 cQuery := "SELECT GMJ.GMJ_CODAGE, GMJ.GMJ_QUARTO, GMJ.GMJ_HORAGE, GMJ.GMJ_CODCRM, GMJ.GMJ_STATUS, GMJ.GMJ_CODLOC, GMD.GMD_INTMAR "
 cQuery += "FROM " + RetSqlName("GMJ") + " GMJ "
 If !lRemaneja
  cQuery += "LEFT JOIN " + RetSqlName("GAV") + " GAV ON (GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_CODLOC = GMJ.GMJ_CODLOC AND GAV.GAV_QUARTO = GMJ.GMJ_QUARTO AND GAV.GAV_TIPO = '2') "
  cQuery += "LEFT JOIN " + RetSqlName("GMH") + " GMH ON (GMH.GMH_FILIAL = '" + xFilial("GMH") + "' AND GMH.D_E_L_E_T_ <> '*' AND GMH.GMH_CODDIS = GMJ.GMJ_CODDIS AND GMH.GMH_CODPLA = '" + cCodPla + "') "

 EndIf
 
 cQuery += "LEFT JOIN " + RetSqlName("GMD") + " GMD ON (GMD.GMD_FILIAL = '" + xFilial("GMD") + "' AND GMD.D_E_L_E_T_ <> '*' AND GMJ.GMJ_CODDIS = GMD.GMD_CODDIS) "

If !lRemaneja
 cQuery += "," + RetSqlName("GMI") + " GMI " 
Endif

 cQuery += "WHERE GMJ.D_E_L_E_T_ <> '*' AND GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.GMJ_FILAGE = '" + M->GMJ_FILAGE + "' AND GMJ.GMJ_DATAGE = '" + DtoS(cDataAtu) + "'  " 


If !lRemaneja

	cQuery += " AND GMI.GMI_FILIAL = '" + xFilial("GMI") + "' AND GMI.D_E_L_E_T_ <> '*' AND GMI.GMI_CODDIS = GMJ.GMJ_CODDIS AND GMI.GMI_CODPRO = '" + cCodPro + "' "
	For nCont := 1 To Len(aCposGea)
		cQuery += " AND EXISTS (SELECT GMI.GMI_CODPRO "
		cQuery += " FROM " + RetSqlName("GMI") + " GMI "
		cQuery += "	WHERE	GMI.GMI_CODDIS = GMJ.GMJ_CODDIS AND GMI.GMI_CODPRO = '" + aCposGea[nCont] + "') "
	Next


Endif


 
 If cDataAtu  == dDataBase
 	cQuery +=	"   AND GMJ.GMJ_HORAGE >= '" + Time() + "' "
 EndIf
 
 If lRemaneja                  
  cQuery += " AND GMJ.GMJ_STATUS IN ('0','1') AND GMJ.GMJ_CODLOC = '" + cSetorDe + "' "
 Else
  cQuery += " AND ((GMJ.GMJ_STATUS = '1' AND GMJ.GMJ_CODCRM = '" + cCodCrm + "') OR (GMJ.GMJ_STATUS = '0' AND GMJ.GMJ_CRMPRI IN ('" + cCodCrm + "', '" + CriaVar("GMJ_CODCRM", .F.) + "' ) )) "
 EndIf
 
 cQuery += "ORDER BY GMJ.GMJ_CODLOC, GMJ.GMJ_QUARTO, GMJ.GMJ_HORAGE "
 
 //cQuery := ChangeQuery(cQuery)
 
 DbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), "TMPHOR", .F., .F.)
  
 DbSelectArea("TMPHOR")
 DbGoTop()
  
 nCont := 0
 cSala	:= ""
 
 If lRemaneja
  CursorWait()
 EndIf
   
 Do While !Eof()

	 nCont := 1
		cSala := TMPHOR->GMJ_CODLOC + TMPHOR->GMJ_QUARTO

		oGetGmj:AddLine(.F., .F.)
  oGetGmj:lNewLine := .F.    

		oGetGmj:aCols[Len(oGetGmj:aCols), nUsadGMJ]	 := .F.
		oGetGmj:aCols[Len(oGetGmj:aCols), nCont   ]	 := TMPHOR->GMJ_CODLOC + "-" + TMPHOR->GMJ_QUARTO
		 
		cCodCCu := HS_IniPadr("GCS", 1, TMPHOR->GMJ_CODLOC, "GCS_CODCCU",, .F.)
		cSqlEqp1 := cSqlEqp
		
		//[cCodCCu]
		cSqlEqp := StrTran(cSqlEqp, "[cCodCCu]" , cCodCCu )
		
		Do While !Eof() .And. cSala == TMPHOR->GMJ_CODLOC + TMPHOR->GMJ_QUARTO
		 If !lRemaneja
    lDispOk := (TMPHOR->GMJ_CODCRM == cCodCrm .And. TMPHOR->GMJ_STATUS == "1")
    If !lDispOk .And. GMJ->(FieldPos("GMJ_USAEQP")) > 0 .And. M->GMJ_USAEQP == "1"
     cDatHorI := DToS(cDataAtu) + TMPHOR->GMJ_HORAGE
     cDatHorF := DToS(cDataAtu) + HS_TotHoras(TMPHOR->GMJ_HORAGE, TMPHOR->GMD_INTMAR)
   
     //[cCodCCu][cDatHorF][cDatHorI]
     cSqlEqp2 := cSqlEqp
      
     cSqlEqp := StrTran(cSqlEqp, "[cDatHorF]", cDatHorF)
     cSqlEqp := StrTran(cSqlEqp, "[cDatHorI]", cDatHorI) 
 
     DbUseArea(.T., "TOPCONN", TcGenQry(,, cSqlEqp), "TMPEQP", .F., .F.)

     lDispOk := Eof() // Caso nao encontre registro o horário esta liberado para os equipamentos do procedimento.

     DbCloseArea()
      
     cSqlEqp := cSqlEqp2
     DbSelectArea("TMPHOR")
    ElseIf !lDispOk .And. GMJ->(FieldPos("GMJ_USAEQP")) > 0 .And. M->GMJ_USAEQP == "0" // Quando o campo usa equipamento for igual a não
     lDispOk := .T. 
    EndIf

    If lDispOk
		   nCont++									                         

		 	 If aScan(aAgeTrfCan, TMPHOR->GMJ_CODAGE) > 0
		 	  oGetGmj:aCols[Len(oGetGmj:aCols), nCont] := "BR_AZUL"
		 	 ElseIf aScan(aAgeGrv, TMPHOR->GMJ_CODAGE) > 0
		 	  oGetGmj:aCols[Len(oGetGmj:aCols), nCont] := "BR_AMARELO"
		 	 Else
 	 	  oGetGmj:aCols[Len(oGetGmj:aCols), nCont] := IIF(!Empty(TMPHOR->GMJ_CODCRM), "BR_VERMELHO", "BR_VERDE")
 	 	 EndIf 

	  	 nCont++
	  	 oGetGmj:aCols[Len(oGetGmj:aCols), nCont] := TMPHOR->GMJ_HORAGE

    EndIf
   Else
    nCont++									                          	
			 oGetGmj:aCols[Len(oGetGmj:aCols), nCont] := IIF(!Empty(TMPHOR->GMJ_CODCRM), "BR_VERMELHO", "BR_VERDE")
	 	 nCont++
	 	 oGetGmj:aCols[Len(oGetGmj:aCols), nCont] := TMPHOR->GMJ_HORAGE
   EndIf
	  DbSkip()
    
	 EndDo
	 cSqlEqp := cSqlEqp1

 EndDo
 
 // Para medir o desenpenho dessa rotina basta desabilitar as linhas com o marcador [DESEMP].
 //cHoraFin := Time()
 //HS_MsgInf("Hora Inicial [" + __cTime + "] Hora Final [" + cHoraFin + "] Tempo gasto [" + HS_TotHoras(__cTime, cHoraFin, "-", .T., .F.) + "]", "Atenção", "Validação dos esquipamentos")
 
 If lRemaneja
	 CursorArrow()
	EndIf

 DbSelectArea("TMPHOR")
 DbCloseArea()
 
 If ValType(nQtdHDis) == "U"
 	nQtdHDis := GetNewPar("MV_QTHRAGC",48)
 EndIf

 If Len(oGetGmj:aCols) == 0
 	oGetGmj:AddLine(.F., .F.)
  oGetGmj:lNewLine := .F.    

 	nCols := 0
		oGetGmj:aCols[Len(oGetGmj:aCols), 1] := Space(Len(GMJ->GMJ_CODLOC)) + " - " + Space(Len(GMJ->GMJ_QUARTO))                                      
		For nCont := 1 To nQtdHDis                                                       
		 nCols++
		 oGetGmj:aCols[Len(oGetGmj:aCols), nCols] := ""                                                   
		 
		 nCols++
		 oGetGmj:aCols[Len(oGetGmj:aCols), nCols] := Space(Len(GMJ->GMJ_CODLOC)) + " - " + Space(Len(GMJ->GMJ_QUARTO))                                      
	 Next nCont
	 oGetGmj:aCols[Len(oGetGmj:aCols), nUsadGMJ]	:= .F.
 EndIf      
                                                                                                
 oGetGmj:oBrowse:Refresh()
 oGetGmj:LACTIVE := .T.
 
 CursorArrow()
 
 RestArea(aArea)
 
Return(.T.)


Static Function FS_MudaMes(cCodCrm, cCodPla, cCodPro, aCGea, nIGea)

 Local cSql := "", aArea := GetArea()
 Local dInicio, dFinal
 Local aCposGea := {}, nCont := 0
 
 Default aCGea := {}
 
 dInicio := FirstDay(oCalSala:dDiaAtu)
 dFinal  := LastDay(oCalSala:dDiaAtu)
 
 dInicio := IIF(dInicio < dDataBase, dDataBase, dInicio) 
 dFinal  := LastDay(dInicio)
 
 oCalSala:Refresh()
 
 If (Empty(cCodPro) .Or. Empty(cCodCrm) .Or. Empty(cCodPla)) .And. !lRemaneja
  RestArea(aArea)
  Return(.T.)
 EndIf
 
 CursorWait()            
 
 If nIGea <> Nil
  AADD(aCposGea, PADR(M->GEA_CODPRO, Len(GEA->GEA_CODPRO)))                       
 EndIf 
 For nCont := 1 To Len(aCGea)
  If !EMPTY(aCGea[nCont, nGeaCodPro]) .And. !aCGea[nCont, nUGEA + 1] .And. IIF(nIGea <> Nil, nCont <> nIGea, .T.)
   AADD(aCposGea, PADR(aCGea[nCont, nGeaCodPro], Len(GEA->GEA_CODPRO)))                       
  EndIf 
 Next

cSql := "SELECT GMJ.GMJ_DATAGE, COUNT(*) AS NVAGAS "
cSql += "FROM " + RetSqlName("GMJ") + " GMJ "
cSql += "LEFT JOIN " + RetSqlName("GAV") + " GAV ON (GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GMJ.GMJ_CODLOC = GAV.GAV_CODLOC AND GMJ.GMJ_QUARTO = GAV.GAV_QUARTO AND GAV.GAV_TIPO = '2') "
cSql += "LEFT JOIN " + RetSqlName("GMH") + " GMH ON (GMH.GMH_FILIAL = '" + xFilial("GMH") + "' AND GMH.D_E_L_E_T_ <> '*' AND GMJ.GMJ_CODDIS = GMH.GMH_CODDIS AND GMH.GMH_CODPLA = '" + cCodPla + "') "
cSql += "," + RetSqlName("GMI") + " GMI "

cSql += "WHERE (GMJ.D_E_L_E_T_ <> '*' AND GMJ.GMJ_FILIAL = '" + xFilial( "GMJ") + "' AND GMJ.GMJ_FILAGE = '" + M->GMJ_FILAGE + "') AND "
If dDataBase == dInicio
	cSql += "((GMJ.GMJ_DATAGE = '" + DtoS(dInicio) + "' AND GMJ.GMJ_HORAGE >= '" + Time() + "') OR (GMJ.GMJ_DATAGE BETWEEN '" + DtoS(dInicio + 1) + "' AND '" + DToS(dFinal) + "')) AND "
Else
	cSql += "(GMJ.GMJ_DATAGE BETWEEN '" + DtoS(dInicio) + "' AND '" + DToS(dFinal) + "') AND "
EndIf
cSql += "((GMJ.GMJ_STATUS = '0' AND GMJ.GMJ_CRMPRI IN ('" + cCodCrm + "', '" + CriaVar("GMJ_CODCRM", .F.) + "' )) OR (GMJ.GMJ_STATUS = '1' AND GMJ.GMJ_CODCRM = '" + cCodCrm + "')) "
cSql += "AND GMI.GMI_FILIAL = '" + xFilial("GMI") + "' AND GMI.D_E_L_E_T_ <> '*' AND GMJ.GMJ_CODDIS = GMI.GMI_CODDIS AND GMI.GMI_CODPRO = '" + cCodPro + "' "
For nCont := 1 To Len(aCposGea)
	cSql += " AND EXISTS (SELECT GMI.GMI_CODPRO
	cSql += "             FROM " + RetSqlName("GMI") + " GMI "
	cSql += "				         WHERE	GMI.GMI_CODDIS = GMJ.GMJ_CODDIS AND GMI.GMI_CODPRO = '" + aCposGea[nCont] + "') "
Next
cSql += "GROUP BY GMJ.GMJ_DATAGE "
cSql += "ORDER BY GMJ.GMJ_DATAGE"

 
 cSql := ChangeQuery(cSql)
 
 DbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "TMPCAL", .F., .F.)
 TCSetField("TMPCAL", "GMJ_DATAGE", "D", 8, 0)

 DbSelectArea("TMPCAL")
 While !Eof()
  If HS_IsFreeDay(TMPCAL->GMJ_DATAGE)
   oCalSala:AddRestri(Day(TMPCAL->GMJ_DATAGE), CLR_RED, CLR_RED)
  Else
   oCalSala:AddRestri(Day(TMPCAL->GMJ_DATAGE), CLR_GREEN, CLR_GREEN)
  EndIf 
 
  DbSkip()
 EndDo                                                             
                     
 DbGoTop()
                                          
 If !lAgendar .And. SubStr(DToS(dInicio), 1, 6) == SubStr(DToS(M->GMJ_DATAGE), 1, 6)
  oCalSala:dDiaAtu := M->GMJ_DATAGE
 Else
  oCalSala:dDiaAtu := IIF(Empty(TMPCAL->GMJ_DATAGE), dInicio, TMPCAL->GMJ_DATAGE)
 EndIf 
 oCalSala:Refresh()
 
 DbSelectArea("TMPCAL")
 DbCloseArea()
 
 CursorArrow()
 
 RestArea(aArea)
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³FS_SALESCO³ Autor ³ Robson Ramiro Oliveira³ Data ³ 29.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria uma consulta para sala e horario disponivel           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSP                                         													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SALESCO(aAgeMar, aAgeLock, nOpcM39)

 Local cHorMax := "", aArea := GetArea(), nMarcAnt := 0
 Local cTmpCodLoc := SubStr(oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1], 1, At("-", oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1]) - 1) 
 Local cSqlVld:="", cQuarto :="", cHora :=""
         
 If Len(oGetGMJ:aCols) > 0 .And. !lPreint
 
	 If oGetGMJ:oBrowse:nColPos > 1 .And. oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, oGetGMJ:oBrowse:nColPos - 1] $ "BR_VERDE/BR_AMARELO" ;
     .And. FS_VldDbCl(cTmpCodLoc, nOpcM39) .And. FS_VldAge()
   
   If !lRemaneja
    M->GMJ_CODLOC := cTmpCodLoc
		  M->GMJ_QUARTO := SubStr(oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1], At("-", oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1]) + 1, Len(GMJ->GMJ_QUARTO))
		  M->GMJ_DATAGE := oCalSala:dDiaAtu
		  M->GMJ_HORAGE := oGetGmj:aCols[oGetGMJ:oBrowse:nAt, oGetGMJ:oBrowse:nColPos]
		  		  
		  DbSelectArea("GMJ") 		 
		  DbSetOrder(4) // GMJ_FILIAL + GMJ_FILAGE + GMJ_CODLOC + GMJ_QUARTO + GMJ_DATAGE + GMJ_HORAGE + GMJ_STATUS
		  DbSeek(xFilial("GMJ") + M->GMJ_FILAGE + M->GMJ_CODLOC + M->GMJ_QUARTO + DTOS(M->GMJ_DATAGE) + M->GMJ_HORAGE)
		 			
		  cHorMax := HS_TotHoras(oGetGmj:aCols[oGetGMJ:oBrowse:nAt, oGetGMJ:oBrowse:nColPos], M->GMJ_TEMPRO)
		   
		  // Verifica se o registro não esta em uso em uma outra reserva que ainda nao foi confirmada.
    While !Eof() .And. GMJ->GMJ_FILAGE == M->GMJ_FILAGE .And. GMJ->GMJ_CODLOC == M->GMJ_CODLOC .And. GMJ->GMJ_QUARTO == M->GMJ_QUARTO .And. ;
		                     GMJ->GMJ_DATAGE == M->GMJ_DATAGE .And. GMJ->GMJ_HORAGE >= M->GMJ_HORAGE .And. GMJ->GMJ_HORAGE  < cHorMax
		                    
     If !LockByName("M39GMJ" + GMJ->GMJ_CODAGE, .T., .T., .F.)
			   HS_MsgInf(STR0040, STR0033, STR0001) //"O horário selecionado está em uso por outro usuário."###"Atenção"###"Agenda Cirúrgica"
			   Return(.F.)            
			  Endif
			   		   		    
		   DbSkip()
		  EndDo
    
    For nMarcAnt := 1 To Len(aAgeMar)
     If aAgeMar[nMarcAnt][1] <= Len(oGetGMJ:aCols)
      If !Empty(oGetGMJ:aCols[aAgeMar[nMarcAnt][1], aAgeMar[nMarcAnt][2]+1])
       oGetGMJ:aCols[aAgeMar[nMarcAnt][1], aAgeMar[nMarcAnt][2]] := "BR_VERDE"
      Endif 
     Endif
     UnLockByName("M39GMJ" + aAgeLock[nMarcAnt], .T., .T., .F.)
    Next                                                                                                         
   
    DbSeek(xFilial("GMJ") + M->GMJ_FILAGE + M->GMJ_CODLOC + M->GMJ_QUARTO + DTOS(M->GMJ_DATAGE) + M->GMJ_HORAGE)
		  
		  aAgeGrv   := {}
		  aAgeMar   := {}
		  aAgeLock  := {}
		  
		  nMarcAnt := oGetGMJ:oBrowse:nColPos - 1
		  While !Eof() .And. GMJ->GMJ_FILAGE == M->GMJ_FILAGE .And. GMJ->GMJ_CODLOC == M->GMJ_CODLOC .And. GMJ->GMJ_QUARTO == M->GMJ_QUARTO .And. ;
		                      GMJ->GMJ_DATAGE == M->GMJ_DATAGE .And. GMJ->GMJ_HORAGE >= M->GMJ_HORAGE .And. GMJ->GMJ_HORAGE  < cHorMax
    
		   aAdd(aAgeGrv, GMJ->GMJ_CODAGE)
		   
		   oGetGmj:aCols[oGetGMJ:oBrowse:nAt, nMarcAnt] := "BR_AMARELO"
		 		    	  
		   aAdd(aAgeMar, {oGetGMJ:oBrowse:nAt, nMarcAnt})
		  
		   aAdd(aAgeLock, GMJ->GMJ_CODAGE)
		    
		   nMarcAnt += 2                           
		   
		   DbSkip()
		  EndDo
    		  		  
		  HS_BEqpAge()
			
			ElseIf Len(oGetTrab:aCols) > 0 .And. IIF(lRemaneja, ValType(oGetTrab:aCols[oGetTrab:oBrowse:nAt, 1]) # "U", .T.)
			
 			cQuarto := SubStr(oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1], At("-", oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1]) + 1, Len(GMJ->GMJ_QUARTO))
		  cHora   := oGetGmj:aCols[oGetGMJ:oBrowse:nAt, oGetGMJ:oBrowse:nColPos]
		   
		  DbSelectArea("GMJ") 		 
		  DbSetOrder(4) // GMJ_FILIAL + GMJ_FILAGE + GMJ_CODLOC + GMJ_QUARTO + GMJ_DATAGE + GMJ_HORAGE + GMJ_STATUS
		  DbSeek(xFilial("GMJ") + M->GMJ_FILAGE + cTmpCodLoc + cQuarto + DTOS(oCalSala:dDiaAtu) + cHora)
    
		  cHorMax := HS_TotHoras(oGetGmj:aCols[oGetGMJ:oBrowse:nAt, oGetGMJ:oBrowse:nColPos], M->GMJ_TEMPRO)
		  
		  // Verifica se o registro não esta em uso em uma outra reserva que ainda nao foi confirmada.
    While !Eof() .And. GMJ->GMJ_FILAGE == M->GMJ_FILAGE .And. GMJ->GMJ_CODLOC == cTmpCodLoc .And. GMJ->GMJ_QUARTO == cQuarto .And. ;
		                      GMJ->GMJ_DATAGE == oCalSala:dDiaAtu .And. GMJ->GMJ_HORAGE >= cHora .And. GMJ->GMJ_HORAGE  < cHorMax

     If !LockByName("M39GMJ" + GMJ->GMJ_CODAGE, .T., .T., .F.)
			   HS_MsgInf(STR0040, STR0033, STR0001) //"O horário selecionado está em uso por outro usuário."###"Atenção"###"Agenda Cirúrgica"
			   aAgeGrv :={}
			   Return(.F.)            
			  EndIf
		   		    
		   DbSkip()
		  EndDo
		  
		  DbSeek(xFilial("GMJ") + M->GMJ_FILAGE + cTmpCodLoc + cQuarto + DTOS(oCalSala:dDiaAtu) + cHora)
		  
		  aAgeGrv  := {}
		  aAgeMar  := {}
		  aAgeLock := {}
		  
		  nMarcAnt := oGetGMJ:oBrowse:nColPos - 1
		  While !Eof() .And. GMJ->GMJ_FILAGE == M->GMJ_FILAGE .And. GMJ->GMJ_CODLOC == cTmpCodLoc .And. GMJ->GMJ_QUARTO == cQuarto .And. ;
		                      GMJ->GMJ_DATAGE == oCalSala:dDiaAtu .And. GMJ->GMJ_HORAGE >= cHora .And. GMJ->GMJ_HORAGE < cHorMax
    
		   aAdd(aAgeGrv, GMJ->GMJ_CODAGE)
		   
		   aAdd(aAgeMar, {oGetGMJ:oBrowse:nAt, nMarcAnt})
		  
		   aAdd(aAgeLock, GMJ->GMJ_CODAGE)
		    
		   nMarcAnt += 2                           
		   
		   DbSkip()
		  EndDo
		  			  
		  Begin Transaction
   
     // Grava agenda cirurgica
     FS_GrvM39(nOpcM39)
   
    End Transaction
  
    While __lSx8
     ConfirmSx8()
    End  
		  
		  //Remontar horarios se for na realocacao...              
    If lRemaneja
     oGetTrab:aCols := {}
     oGetTrab:oBrowse:Refresh()
     FS_BrwSalas(M->GMJ_CODPRO, M->GMJ_CODCRM, M->GMJ_CODPLA)
     oGetGmj:oBrowse:Refresh()
    EndIf 	  
			
			EndIf 
			
			oGetGmj:oBrowse:Refresh()
			
		ElseIf oGetGMJ:oBrowse:nColPos > 1 .And. oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, oGetGMJ:oBrowse:nColPos - 1] $ "BR_VERMELHO" ;
		       .And. lRemaneja
		
		 M->GMJ_CODLOC := cTmpCodLoc
		 M->GMJ_QUARTO := SubStr(oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1], At("-", oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1]) + 1, Len(GMJ->GMJ_QUARTO))
		 M->GMJ_DATAGE := oCalSala:dDiaAtu
		 M->GMJ_HORAGE := oGetGmj:aCols[oGetGMJ:oBrowse:nAt, oGetGMJ:oBrowse:nColPos]
		 
		 DbSelectArea("GMJ")		 
		 DbSetOrder(4) // GMJ_FILIAL + GMJ_FILAGE + GMJ_CODLOC + GMJ_QUARTO + GMJ_DATAGE + GMJ_HORAGE + GMJ_STATUS
		 DbSeek(xFilial("GMJ") + M->GMJ_FILAGE + M->GMJ_CODLOC + M->GMJ_QUARTO + DTOS(M->GMJ_DATAGE) + M->GMJ_HORAGE)
	  M->GMJ_CODAGE := GMJ->GMJ_SEQAGE
	  M->GMJ_TEMPRO := GMJ->GMJ_TEMPRO
	  M->GMJ_USAUTI := GMJ->GMJ_USAUTI
		
		 cSqlVld:= "SELECT GMJ.GMJ_DATAGE, GMJ.GMJ_HORAGE "
   cSqlVld+= "FROM " + RetSqlName("GMJ") + " GMJ "
   cSqlVld+= "WHERE GMJ.D_E_L_E_T_ <> '*' AND GMJ.GMJ_FILIAL ='" + xFilial("GMJ") + "' AND "
   cSqlVld+=       "GMJ.GMJ_CODAGE = '" + M->GMJ_CODAGE + "'  AND GMJ.GMJ_CODAGE = GMJ.GMJ_SEQAGE "
                         
   cSqlVld := ChangeQuery(cSqlVld)
   DbUseArea(.T., "TOPCONN", TcGenQry(,, cSqlVld), "TMPVLD", .F., .F.)
   
   DbSelectArea("TMPVLD")
   DbGoTop()
   If TMPVLD->GMJ_HORAGE >= Time() .Or. TMPVLD->GMJ_DATAGE > DTOS(dDatabase)
    oGetTrab:aHeader := {}
    oGetTrab:aCols   := {}
    HS_BDados("GMJ", @oGetTrab:aHeader, @oGetTrab:aCols,, 8,,"GMJ->GMJ_SEQAGE == '" + M->GMJ_CODAGE + "'")
    oGetTrab:oBrowse:Refresh()
    aAgeTrfCan := FS_BCodAge(M->GMJ_CODAGE)
    aAgeGrv    := aClone(aAgeTrfCan)
   Else
    HS_MsgInf(STR0041, STR0033, STR0001) //"Não será possível transferir o horário escolhido na agenda, pois o horário já foi expirado."###"Atenção"###"Agenda Cirúrgica"
   EndIf
		 
		 DbSelectArea("TMPVLD")
		 DbCloseArea()		
		
		EndIf
		
 EndIf
      
 RestArea(aArea)                                            	
 
Return(.T.)


//  cCpoVld  => Campo que esta sendo validado no momento
//  lVldFora => Quando a funcao e chamada de dentro do fonte .T. = Nao valida PLano
//                                                           .F. = Valida Plano
Function HS_VldM39(cCpoVld,lVldFora)

 Local lRet     := .T. , lPlaPad := .F.
 Local aAreaGMJ :={}, aCpoIni := {}, aCpoFim := {}
 Local rLstMed  := ""
 Local cHoraFi  := HS_TotHoras(M->GMJ_HORAGE, M->GMJ_TEMPRO)
 Local aRetEqp  := {}
 Local cCodGrp  := ""
 Local nPosGrp  := 0
 Local cMsgProDia := ""
 
 Default cCpoVld  := ReadVar()
 Default lVldFora := .F.

 // Validações do prontuário do paciente                     
 If cCpoVld == "M->GMJ_REGGER"      
  If !Empty(M->GMJ_REGGER)
   If !lVldFora
    // Valida cadastro de pacientes
    If !(lRet := HS_SeekRet("GBH", "M->GMJ_REGGER", 1, .F., {"GMJ_TELPAC", "GMJ_NOMPAC"}, {"GBH_TEL", "GBH_NOME"},,, .T.))
     HS_MsgInf(STR0042 + AllTrim(M->GMJ_REGGER) + STR0043, STR0033, STR0074) //"Prontuário ["###"], não encontrado."###"Atenção"###"Validações do prontuário do paciente."
     
    // Valida plano principal do paciente 
    ElseIf !(lPlaPad := HS_SeekRet("GD4", "M->GMJ_REGGER + '1'", 2, .F., {"GMJ_CODPLA", "GMJ_MATRIC"}, {"GD4_CODPLA", "GD4_MATRIC"},,, .T.))
     HS_MsgInf(STR0044 + AllTrim(M->GMJ_REGGER) + "]", STR0033, STR0074) //"Não foi possível identificar o plano principal do prontuário ["###"Atenção"###"Validações do prontuário do paciente."
    
    // Valida cadastro de planos 
    EndIf
    If lPlaPad .And. !(lRet := HS_SeekRet("GCM", "M->GMJ_CODPLA", 2, .F., "GMJ_DESPLA", "GCM_DESPLA",,, .T.))
     HS_MsgInf(STR0045 + AllTrim(M->GMJ_CODPLA) + STR0046 + AllTrim(M->GMJ_REGGER) + STR0047, STR0033, STR0074) //"O plano ["###"] do prontuário ["###"], não foi encontrado no Cadastro de Planos"###"Atenção"###"Validações do prontuário do paciente."
			 EndIf
			 
			 If lRet
     M->GMJ_CODPRO:= Space(Len(GMJ->GMJ_CODPRO))
    EndIf 
			EndIf
			 // Validacao de prontuarios com agendas de um mesmo procedimento em determinado dia	
   If !Empty(M->GMJ_REGGER) .And. !Empty(M->GMJ_CODPRO) .And. !Empty(oCalSala:dDiaAtu)
    aAreaGMJ := GetArea()
    DbSelectArea("GMJ")
    DbSetOrder(5) // GMJ_FILIAL + GMJ_REGGER + DTOS(GMJ_DATAGE) + GMJ_CODPRO
    If DbSeek(xFilial("GMJ") + M->GMJ_REGGER + DTOS(oCalSala:dDiaAtu) + M->GMJ_CODPRO)
     lRet := .F.
     HS_MsgInf(STR0048 + AllTrim(M->GMJ_REGGER) + STR0049 + AllTrim(M->GMJ_CODPRO) + STR0050 , STR0033, STR0074) //"O prontuário ["###"] já possui agendamento para o procedimento ["###"] nesta data."###"Atenção"###"Validações do prontuário do paciente."
    EndIf
    
    If lRet
     DbSelectArea("GMJ")
     DbSetOrder(7) // GMJ_FILIAL+GMJ_REGGER+GMJ_CODPRO+DTOS(GMJ_DATAGE)+GMJ_STATUS
     If DbSeek(xFilial("GMJ") + M->GMJ_REGGER + M->GMJ_CODPRO)
      
      cMsgProDia := ""
      While !GMJ->(EOF()) .And. (GMJ->GMJ_CODPRO == M->GMJ_CODPRO) .And. (GMJ->GMJ_REGGER == M->GMJ_REGGER)
       If (GMJ->GMJ_DATAGE > dDataBase)    
        If !(DTOC(GMJ->GMJ_DATAGE) $ cMsgProDia)
         cMsgProDia += IIF(Empty(cMsgProDia),"",", ")+ DTOC(GMJ->GMJ_DATAGE)
        EndIf 
       EndIf
       DbSkip()
      End
      
      If !Empty(cMsgProDia)
       HS_MsgInf(STR0048 + AllTrim(M->GMJ_REGGER) + STR0049 + AllTrim(M->GMJ_CODPRO) + "] !" + STR0093 + cMsgProDia , STR0033, STR0074) //"O prontuário ["###"] já possui agendamento para este procedimento [###]! na(s) data(s) "###"Atenção"###"Validações do prontuário do paciente."      
      EndIf
     EndIf    
    EndIf

    RestArea(aAreaGMJ)
    
   EndIf
   
	  If lRet
    M->GMJ_IDADE := StrZero(HS_DifData(GBH->GBH_DTNASC, dDataBase)[1], 3)
   EndIf           
	 EndIf
	 
	 If lRet := HS_VldPac(M->GMJ_REGGER)
   M->GMJ_SQCATP := GD4->GD4_SQCATP
   M->GMJ_DSCATP := HS_IniPadr("GFV", 1, GD4->GD4_CODPLA + GD4->GD4_SQCATP, "GFV_NOMCAT",, .F.)
  Else
   Return(.F.)
  EndIf  
	 
	 cGfvPlano  := M->GMJ_CODPLA
	 cGD4RegGer := IIF(lRet, M->GMJ_REGGER, Space(Len(M->GMJ_REGGER)))
  cGczCodPla := IIF(lRet, M->GMJ_CODPLA, Space(Len(M->GMJ_CODPLA)))
	
	// Validação do nome do paciente 
	ElseIf cCpoVld == "M->GMJ_NOMPAC"
	 
	 // Valida cadastro de pacientes                                                                                               
	 If !Empty(cGbhCodPac)
   M->GMJ_REGGER := cGbhCodPac
   lRet := HS_VldM39("M->GMJ_REGGER")
  EndIf
	
	// Validação da matricula
	ElseIf cCpoVld == "M->GMJ_MATRIC"
	
	 lRet := HS_VMatPla(M->GMJ_MATRIC, M->GMJ_CODPLA)
	 
	ElseIf cCpoVld == "M->GMJ_SQCATP"
 	
 	If !(lRet := HS_SeekRet("GFV","M->GMJ_CODPLA + M->GMJ_SQCATP", 1, .F., "GMJ_DSCATP", "GFV_NOMCAT",,, .T.))
   HS_MsgInf(STR0085, STR0033, STR0074) //"Categoria não encontrada."###"Atenção"###"Validações do prontuário do paciente."
   lRet := .F.
  ElseIf GFV->GFV_STATUS == "0"
   HS_MsgInf(STR0086, STR0033, STR0074) //"Categoria inativa para o plano."###"Atenção"###"Validações do prontuário do paciente."
   lRet := .F.
  EndIf
	
	// Validacao do codigo do plano do paciente
	ElseIf cCpoVld == "M->GMJ_CODPLA"
	 
	 // Valida cadastro de plano
	 If !(lRet := HS_SeekRet("GCM", "M->GMJ_CODPLA", 2, .F., {"GMJ_DESPLA", "GMJ_CODCON"}, {"GCM_DESPLA", "GCM_CODCON"},,, .T.))
   HS_MsgInf(STR0051 + AllTrim(M->GMJ_CODPLA) + STR0043, STR0033, STR0074) //"Plano ["###"], não encontrado."###"Atenção"###"Validações do prontuário do paciente."
    
  // Valida cadastro de convenio
  ElseIf !(lRet := HS_SeekRet("GA9", "M->GMJ_CODCON", 1, .F.,,,,, .T.))
   HS_MsgInf(STR0052 + AllTrim(M->GMJ_CODCON) + STR0043, STR0033, STR0074) //"Convênio ["###"], não encontrado."###"Atenção"###"Validações do prontuário do paciente."
   
  // Valida planos nao permitidos no setor 
  ElseIf !(lRet := !HS_SeekRet("GM0", "cGcsCodLoc+M->GMJ_CODPLA", 1, .F.,,,,, .T.))
   HS_MsgInf(STR0051 + AllTrim(M->GMJ_CODPLA) + STR0053 + cGcsCodLoc + "]", STR0033, STR0074) //"Plano ["###"], não permitido no setor ["###"Atenção"###"Validações do prontuário do paciente."      
  EndIf
  
  If lRet .And. (lRet := HS_VMatPla(M->GMJ_MATRIC, M->GMJ_CODPLA))
   If lRet := HS_VldPac(M->GMJ_REGGER, M->GMJ_CODPLA)
    M->GMJ_SQCATP := GD4->GD4_SQCATP
    M->GMJ_DSCATP := HS_IniPadr("GFV", 1, GD4->GD4_CODPLA + GD4->GD4_SQCATP, "GFV_NOMCAT",, .F.)
   Else
    Return(.F.)
   EndIf  
	 
 	 cGfvPlano  := M->GMJ_CODPLA      
   cObsPlano  := IIF(lRet, GA9->GA9_OBSERV, "") // Observacao do Plano
   cGczCodPla := IIF(lRet, M->GMJ_CODPLA  , Space(Len(M->GMJ_CODPLA))) // Codigo do plano
   
  EndIf 
  	 	 
	// Validação do codigo do procedimento 
 ElseIf cCpoVld == "M->GMJ_CODPRO"  
  
  // Valida cadastro de procedimentos
  If !(lRet := HS_SeekRet("GA7", "M->GMJ_CODPRO", 1, .F., {"GMJ_DESPRO", "GMJ_TEMPRO"}, {"GA7_DESC", "GA7_TEMPRO"},,, .T.))
   HS_MsgInf(STR0054 + AllTrim(M->GMJ_CODPRO) + STR0043, STR0033, STR0074) //"Procedimento ["###"], não encontrado."###"Atenção"###"Validações do prontuário do paciente."
   
  // Valida procedimentos permitidos no setor 
	 ElseIf !(lRet := HS_SeekRet("GM2", "cGcsCodLoc + M->GMJ_CODPRO", 1, .F.,,,,, .T.))
	  HS_MsgInf(STR0054 + AllTrim(M->GMJ_CODPRO) + STR0053 + cGcsCodLoc + "]", STR0033, STR0074) //"Procedimento ["###"], não permitido no setor ["###"Atenção"###"Validações do prontuário do paciente."
	 Else //Valida o Procedimento de acordo com a Idade/Sexo)
 	 DbSelectArea("GBH")
	  DbSetORder(1) // GBH_FLIAL + GBH_CODPAC
	  If DBSeek(xFilial("GBH") + M->GMJ_REGGER)
    lRet := HS_VldISPr(M->GMJ_CODPRO, GBH->GBH_DTNASC, GBH->GBH_SEXO) 
   EndIf
	 EndIf
	 
	 IIF(lRet, lRet:=HS_VldM39("M->GMJ_REGGER",.T.) , Nil)
	 
	 If lRet .And. lAgendar
   aAgeGrv    := {}
   aAgeTrfCan := {}
	 Endif
	 
	 cObsProc   := IIF(lRet, GA7->GA7_OBSERV, "") //Observacao do Procedimento
 	cGbjCodEsp := IIF(lRet, GA7->GA7_CODESP, Space(Len(GA7->GA7_CODESP))) //Especialidade do Procedimento 
 	
	// Validação do codigo do médico (CRM) 
	ElseIf cCpoVld == "M->GMJ_CODCRM"                                                     
	
 	// Valida cadastro de médicos GBJ
  If     !(lRet := HS_SeekRet("GBJ", "M->GMJ_CODCRM", 1, .F.,,,,, .T.))
   HS_MsgInf("(GBJ) " + STR0055 + AllTrim(M->GMJ_CODCRM) + STR0043, STR0033, STR0074) //"Médico ["###"], não encontrado."###"Atenção"###"Validações do prontuário do paciente."
	                                        	 
	 // Valida cadastro de profissionais SRA
	 ElseIf !(lRet := HS_SeekRet("SRA", "M->GMJ_CODCRM", 11, .F., "GMJ_NOMCRM", "RA_NOME",,, .T.))
	  HS_MsgInf("(SRA) " + STR0055 + AllTrim(M->GMJ_CODCRM) + STR0043, STR0033, STR0074) //"Médico ["###"], não encontrado."###"Atenção"###"Validações do prontuário do paciente."
	 	     
	 // Verifica se o médico esta habilitado para agenda cirurgica
	 ElseIf !(lRet := GBJ->GBJ_IDAGEN $ "12") // 1-Agenda Cirurgica 2-Ambas              
 	 HS_MsgInf("(GBJ) " + STR0055 + AllTrim(M->GMJ_CODCRM) + STR0056, STR0033, STR0074) //"Médico ["###"], não permitido na Agenda Cirúrgica."###"Atenção"###"Validações do prontuário do paciente."
 	 
 	// Valida se a especialidade do médico é compativel com a especialidade do procedimento
  Else
   cGbjCodEsp := IIF(!EMPTY(M->GMJ_CODPRO), HS_IniPadR("GA7", 1, M->GMJ_CODPRO, "GA7_CODESP",, .F.), Space(Len(GA7->GA7_CODESP)))
   If !(lRet := cGbjCodEsp $ (rLstMed := HS_REspMed(M->GMJ_CODCRM)))
    HS_MsgInf("(GBJ) " + STR0057 + rLstMed + "] " + ; //"Especialidade ["
              STR0058 + AllTrim(M->GMJ_CODCRM) + STR0059 + AllTrim(M->GMJ_CODPRO) + "] " + ; //"do médico ["###"], não é permitida para a execução do procedimento ["
              STR0060 + cGbjCodEsp + "]", STR0033, STR0074) //"da especialidade ["###"Atenção"###"Validações do prontuário do paciente."
	  EndIf
	 EndIf 
	 
	 cObsProf := IIF(lRet, GBJ->GBJ_OBSERV, "") //Observacao do Profissional 	
	  
	 // No caso de inclusão da agenda executa função de montagem de equipe
	 If lRet .And. lMontaEqp
   FS_EqpMed(M->GMJ_CODCRM)
	 EndIf
	    
	ElseIf cCpoVld == "M->GMJ_USAUTI" .And. !Empty(GMJ->GMJ_CODLOC) .And. M->GMJ_USAUTI = '1'
	 lRet :=	FS_VldDbCl(GMJ->GMJ_CODLOC, 5, .F.)
	 
	ElseIf cCpoVld == "M->GMJ_ORICAN"
	 cGm7OriCan := M->GMJ_ORICAN

 ElseIf cCpoVld == "M->GMJ_MOTIVO" 
  If !(lRet := HS_SeekRet("GM7", "M->GMJ_MOTIVO", 1, .F., "GMJ_DESMOT", "GM7_DESCAN"))
   HS_MsgInf(STR0091, STR0033, STR0074) //###"Motivo do cancelamento não cadastrado"###"Atenção"###"Validações do prontuário do paciente."
  EndIf
	 
	ElseIf cCpoVld == "M->GMJ_USAEQP"
	 If M->GMJ_USAEQP == "1"
// 	 FS_Eqpto(M->GMJ_CODPRO, .T. )
 	Else
// 	 FS_Eqpto(M->GMJ_CODPRO, .F. )
 	EndIf
 ElseIf cCpoVld == "M->GMJ_CODPAT"
  If !(lRet := HS_SeekRet("GAS", "M->GMJ_CODPAT", 1, .F., "GMJ_PATOLO", "GAS_PATOLO"))
   HS_MsgInf(STR0078, STR0033, STR0074) //"Patologia não cadastrada."###"Atenção"###"Validações do prontuário do paciente."
  EndIf
  
 ElseIf cCpoVld == "M->GEA_CODPRO" 
  If !(lRet := HS_SeekRet("GA7", "M->GEA_CODPRO", 1, .F., "GEA_DESCPR", "GA7_DESC"))
   HS_MsgInf(STR0054 + AllTrim(M->GEA_CODPRO) + STR0043, STR0033, STR0074) //"Procedimento ["###"], não encontrado."###"Atenção"###"Validações do prontuário do paciente."
  Else //Valida o Procedimento de acordo com a Idade/Sexo)
 	 DbSelectArea("GBH")
	  DbSetORder(1) // GBH_FILIAL + GBH_CODPAC
	  If DBSeek(xFilial("GBH") + M->GMJ_REGGER)
    lRet := HS_VldISPr(M->GEA_CODPRO, GBH->GBH_DTNASC, GBH->GBH_SEXO) 
   EndIf
   If lRet .And. M->GMJ_CODPRO == M->GEA_CODPRO
    HS_MsgInf(STR0079, STR0033, STR0074) //"Procedimento especial não pode ser igual ao procedimento principal."###"Atenção"###"Validações do prontuário do paciente."
    lRet := .F.
   EndIf
  EndIf

 ElseIf cCpoVld == "M->GET_CODEQP"
  // Busca código do grupo do equipamento para verificar s ja existe um equipamento lancado com esse grupo.
  cCodGrp := HS_IniPadr("GER", 2, M->GET_CODEQP, "GER_CODGRP",, .F.)
  nPosGrp := aScan(oGetGET:aCols, {| aVet | aVet[nGetCodGrp] == cCodGrp})
  
  If !(lRet := HS_SeekRet("ST9","M->GET_CODEQP", 1, .F./*, "GET_DESEQP", "T9_NOME"*/))
   HS_MsgInf(STR0080, STR0033, STR0081) //"Equipamento não encontrado."###"Atenção"###"Validação de Equipamentos"
  ElseIf !(lRet := !(nPosGrp > 0 .And. nPosGrp <> oGetGET:nAt))
   HS_MsgInf("Já existe um equipamento lançado do grupo [" + cCodGrp + "]", STR0033, STR0081) //"Atenção"###"Validação de Equipamentos"
  Else                            
   If lRet := FS_VldDisp(cCpoVld,,, oGetGET:aCols) // Valida disponibilidade do equipamento
    HS_SeekRet("GER", "M->GET_CODEQP", 2, .F.,"GET_CODGRP", "GER_CODGRP")
    HS_SeekRet("GF9", "M->GET_CODGRP", 1, .F.,"GET_DESGRP", "GF9_DESGRP")
    
    aCpoIni := HS_CALCDAT(IIF(!Empty(M->GMJ_DATAGE), M->GMJ_DATAGE, dDataBase) , M->GMJ_HORAGE, "-", GF9->GF9_TEMPOA)
    oGetGET:aCols[oGetGET:nAt, nGetDatAge] := aCpoIni[1]
    oGetGET:aCols[oGetGET:nAt, nGetHorAge] := aCpoIni[2]
    
    aCpoFim := HS_CALCDAT(oGetGET:aCols[oGetGET:nAt, nGetDatAge], cHoraFi, "+", GF9->GF9_TEMPOA)
    oGetGET:aCols[oGetGET:nAt, nGetDatFin] := aCpoFim[1]
    oGetGET:aCols[oGetGET:nAt, nGetHoraFi] := aCpoFim[2]
   EndIf
  EndIf
  
 ElseIf cCpoVld == "M->GET_CODGRP"
  If lVldFora
   M->GET_CODGRP := oGetGET:aCols[oGetGET:nAt, nGetCodGrp]
  EndIf
  nPosGrp := aScan(oGetGET:aCols, {| aVet | aVet[nGetCodGrp] == M->GET_CODGRP})
  
  If !(lRet := HS_SeekRet("GF9", "M->GET_CODGRP", 1, .F./*, "GET_DESGRP", "GF9_DESGRP"*/))
   HS_MsgInf(STR0082, STR0033, STR0081) //"Grupo de equipamentos não encontrado."###"Atenção"###"Validação de Equipamentos"
   
  ElseIf !(lRet := !(nPosGrp > 0 .And. nPosGrp <> oGetGET:nAt))
   HS_MsgInf("Já existe um equipamento lançado do grupo [" + M->GET_CODGRP + "]", STR0033, STR0081) //"Atenção"###"Validação de Equipamentos"
   
  Else                            
   
   If (lRet := FS_VldDisp(cCpoVld,, @aRetEqp, oGetGET:aCols, .F.))
    
    If !Empty(aRetEqp) // Preenche o equipamento automaticamente                             
     oGetGET:aCols[oGetGET:nAt, nGetDesGrp] := GF9->GF9_DESGRP
     oGetGET:aCols[oGetGET:nAt, nGetCodEqp] := aRetEqp[2]
     oGetGET:aCols[oGetGET:nAt, nGetDesEqp] := HS_IniPadr("ST9", 1,aRetEqp[2],"T9_NOME",,.F.)
     //HS_VldM39("M->GET_CODEQP")
     //Solução temporaria para resolver o problema do refresh na consulta GER001 (F3)
     //Problema repassado para a tecnologia mas até o momento sem solução.
     HS_SeekRet("GER", "'" + oGetGET:aCols[oGetGET:nAt, nGetCodEqp] + "'", 2, .F.)
    
     aCpoIni := HS_CALCDAT(IIF(!Empty(M->GMJ_DATAGE), M->GMJ_DATAGE, dDataBase) , M->GMJ_HORAGE, "-", GF9->GF9_TEMPOA)
     oGetGET:aCols[oGetGET:nAt, nGetDatAge] := aCpoIni[1] 
     oGetGET:aCols[oGetGET:nAt, nGetHorAge] := aCpoIni[2] 

     aCpoFim := HS_CALCDAT(oGetGET:aCols[oGetGET:nAt, nGetDatAge], cHoraFi, "+", GF9->GF9_TEMPOA)
  
     oGetGET:aCols[oGetGET:nAt, nGetDatFin] := aCpoFim[1] 
     oGetGET:aCols[oGetGET:nAt, nGetHoraFi] := aCpoFim[2] 
    EndIf 
   EndIf
  EndIf
 ElseIf cCpoVld == "M->GE9_CODCRM"
  If !(lRet := HS_SeekRet("SRA","M->GE9_CODCRM",11,.f.,"GE9_NOMMED","RA_NOME"))
   HS_MsgInf("(GBJ) " + STR0055 + AllTrim(M->GMJ_CODCRM) + STR0043, STR0033, STR0088) //"Médico ["###"], não encontrado."###"Atenção"###"Validações da Equipe Medica"
  EndIf                                    
  
 ElseIf cCpoVld == "M->GE9_TIPATM"
  If !(lRet := HS_SeekRet("GMC","M->GE9_TIPATM",1,.F.,"GE9_DESATO","GMC_DESATO"))
   HS_MsgInf("(GMC) " + STR0089 + AllTrim(M->GE9_TIPATM) + STR0090, STR0033, STR0088) //"Médico ["###"], não encontrado."###"Atenção"###"Validações da Equipe Medica"
  EndIf 
 EndIf 
 
 // Executa montagem de horarios disponiveis levando em consideração a disponibilidade das sala e a disponibilidade dos equepamentos
 If lRet .And. ReadVar() $ "M->GMJ_CODCRM/M->GMJ_CODPLA/M->GMJ_CODPRO/M->GMJ_USAEQP/M->GEA_CODPRO" .And. !Empty(M->GMJ_CODCRM) .And. !Empty(M->GMJ_CODPLA) .And. !Empty(M->GMJ_CODPRO)

  If lAgendar // limpa o que ja estava marcado
   aAgeGrv    := {}
   aAgeTrfCan := {}
	 EndIf
 
  FS_MudaMes(M->GMJ_CODCRM, M->GMJ_CODPLA, M->GMJ_CODPRO, IIf(!lRemaneja, oGetGEA:aCols, Nil), IIf(ReadVar() == "M->GEA_CODPRO", oGetGEA:oBrowse:nAt, Nil))
  
 EndIf
 
Return(lRet)


Static Function FS_DelGET(nOpc)

 Local lRet := .T.
 
 If (nOpc <> 5) // Alterar
  If !Empty(oGetGET:aCols[oGetGET:nAt, nGetCodPro])
   If nOpc == 2
    HS_MsgInf(STR0083, STR0033, STR0081) //"Para excluir equipamentos relacionados a equipamentos salve a reserva e depois use a opção Alterar."###"Atenção"###"Validação de Equipamentos"
   EndIf
   lRet := .F.
  EndIf
 EndIf
 
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VldDispºAutor  ³Luiz Pereira S. Jr. º Data ³  27/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a disponibilidade de um determinado equipamento.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCampo - No caso de chamada atraves de uma validacao de    º±±
±±º          ³          campo, indica qual campo fez a chamada            º±±
±±º          ³ cEqpto - No caso da chamada ser da montagem da getdados de º±±
±±º          ³          equipamentos, indica o equipamento a ser validado º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_VldDisp(cCampo, cEqpto, aREqpto, aEqpVld, lMostraMsg)

 Local aArea   := GetArea()
 Local lRet    := .T.
 Local cSql    := ""
 Local cHoraFi := HS_TotHoras(M->GMJ_HORAGE, M->GMJ_TEMPRO)
 Local cInEqpto := "", nItens := 0
 
 Default cCampo     := ""
 Default cEqpto     := ""
 Default aREqpto    := {}
 Default lMostraMsg := .T.
 
 If aEqpVld <> Nil
  cInEqpto := HS_RetIn(@nItens, oGetGET:aCols, Len(oGetGET:aHeader), nGetCodEqp, oGetGET:nAt, "Pos")
 
  If nItens > 1
   cInEqpto := HS_InSql(cInEqpto, Len(GET->GET_CODGRP))
  ElseIf !Empty(cInEqpto)
   cInEqpto :="'" + cInEqpto +"'"
  EndIf
 EndIf
 
 cSql := "SELECT GER_CODGRP, GER_CODEQP "
 cSql += "FROM " + RetSqlName("GER") + " " 
 cSql += "WHERE GER_FILIAL = '" + xFilial("GER") + "' AND D_E_L_E_T_ <> '*' AND "
 
 If cCampo == "M->GET_CODEQP"
  cSql += "GER_CODEQP = '" + M->GET_CODEQP + "' AND "
 ElseIf cCampo == "M->GET_CODGRP"
  cSql += "GER_CODGRP = '" + M->GET_CODGRP + "' AND "
 ElseIf !Empty(cEqpto)
  cSql += "GER_CODEQP = '" + cEqpto + "' AND "
 EndIf
                            
 If !Empty(cInEqpto)
  cSql += "NOT GER_CODEQP IN ( " + cInEqpto + " ) AND " 
 EndIf
  
 cSql +=    "GER_CODEQP IN ( "
 cSql +=       "SELECT ST9.T9_CODBEM "
 cSql +=       "FROM " + RetSqlName("ST9") + " ST9 "
 cSql +=       "WHERE ST9.T9_SITBEM = 'A' AND ST9.D_E_L_E_T_ <> '*' AND ST9.T9_FILIAL = '" + xFilial("ST9") + "') AND "
 /* A pedido do Wellington e Graciano não é preciso verificar se o equipamento pertence ao grupo de equipamentos 
 // amarrados no procedimento. 16/08/2007 - José Orfeu
 cSql +=    "GER_CODEQP NOT IN ( "
 cSql +=       "SELECT GER.GER_CODEQP "
 cSql +=       "FROM " + RetSqlName("GER") + " GER "
 cSql +=         "JOIN " + RetSqlname("GFA") + " GFA ON GFA.GFA_FILIAL = '" + xFilial("GFA") + "' AND GFA.D_E_L_E_T_ <> '*' AND "
 cSql +=                            "GFA.GFA_CODPRO = '" + M->GMJ_CODPRO + "' AND GFA.GFA_CODGRP = GER.GER_CODGRP "
 cSql +=       "WHERE GER.GER_FILIAL = '  ' AND GER.D_E_L_E_T_ <> '*') AND "
 */
 cSql +=    "GER_CODEQP NOT IN (
 cSql +=       "SELECT STJ.TJ_CODBEM "
 cSql +=       "FROM " + RetSqlName("STJ") + " STJ "
 cSql +=       "WHERE STJ.D_E_L_E_T_ <> '*' AND STJ.TJ_FILIAL = '" + xFilial("STJ") + "' AND STJ.TJ_SITUACA = 'P' AND "
 cSql +=             "STJ.TJ_TERMINO = 'N' AND STJ.TJ_DTMPINI <= '" + DTOS(oCalSala:dDiaAtu) + "' AND "
 cSql +=             "STJ.TJ_HOMPINI < '" + cHoraFi + "' AND "
 cSql +=             "STJ.TJ_DTMPFIM >= '" + DTOS(oCalSala:dDiaAtu) + "' AND "
 cSql +=             "STJ.TJ_HOMPFIM > '" + M->GMJ_HORAGE + "' AND STJ.TJ_TIPOOS = 'B') AND "
 cSql +=    "GER_CODEQP NOT IN (
 cSql +=       "SELECT GET.GET_CODEQP "
 cSql +=       "FROM " + RetSqlName("GET") + " GET "
 cSql +=       "WHERE GET.D_E_L_E_T_ <> '*' AND GET.GET_FILIAL = '" + xFilial("GET") + "' AND "
 cSql +=             "GET.GET_CODAGE <>	'" + M->GMJ_CODAGE + "' AND GET.GET_DATAGE = '" + DTOS(oCalSala:dDiaAtu) + "' AND "
 cSql +=             "GET.GET_HORAGE < '" + cHoraFi + "' AND GET.GET_HORAFI > '" + M->GMJ_HORAGE + "' ) "
	
	cSql := ChangeQuery(cSql)
 
 DbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "TMPDSP", .F., .F.)
 
 DbSelectArea("TMPDSP")
 DbGotop()
 
 If Eof()// Se naum achou o equipamento eh porque naum esta disponivel
  If lMostraMsg .And. Empty(cEqpto)
   HS_MsgInf(IIf(ReadVar()=="M->GET_CODGRP",STR0094,STR0084), STR0033, STR0081) //"Não foi encontrada disponibilidade para o equipamento."###"Atenção"###"Validações de equipamentos"
  EndIf
  lRet := .F.
 Else
  aREqpto := {TMPDSP->GER_CODGRP, TMPDSP->GER_CODEQP}
 EndIf
 
 DbSelectArea("TMPDSP")
 DbCloseArea()
 
 RestArea(aArea)
 
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_EqpMed ³ Autor ³ José Orfeu            ³ Data ³ 28.09.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca equipe medica e inclui na cirurgia                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M39                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_EqpMed(cCodCrm)

 Local cSqlEqp  := "", nMedEqp := 0
 Local aArea    := GetArea()      
 Local nUsadGE9	:= Len(oGetGe9:aHeader) + 1
 
 DBSelectArea("GME")
 DbSetOrder(2) // GME_FILIAL + GME_CODCRM
 If DBSeek(xfilial("GME") + cCodCrm)
  
  cSqlEqp := "SELECT GMF.GMF_CODCRM, SRA.RA_NOME, GMF.GMF_CODATO, GMC.GMC_DESATO "
  cSqlEqp += "FROM " + RetSqlName("GMF") + " GMF "
  cSqlEqp += "JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND GMF.GMF_CODCRM = SRA.RA_CODIGO  "
		cSqlEqp +=	"JOIN " + RetSqlName("GMC") + " GMC ON GMC.GMC_FILIAL = '" + xFilial("GMC") + "' AND GMC.D_E_L_E_T_ <> '*' AND GMF.GMF_CODATO = GMC.GMC_CODATO "
  cSqlEqp += "WHERE GMF.GMF_FILIAL = '" + xFilial("GMF") + "' AND GMF.D_E_L_E_T_ <> '*' AND GMF.GMF_CODEQP = '" + GME->GME_CODEQP + "' "
  cSqlEqp += "ORDER BY " + SqlOrder(GMF->(IndexKey(1)))
  
  cSqlEqp := ChangeQuery(cSqlEqp)
 
  DbUseArea(.T., "TOPCONN", TcGenQry(,, cSqlEqp), "TMPEQP", .F., .F.)
   
  oGetGe9:aCols := {}
  
  While !Eof()
   nMedEqp++
     
   oGetGe9:AddLine(.F., .F.)
   oGetGe9:lNewLine := .F.    
 
   oGetGe9:aCols[nMedEqp, nGe9Item  ] := StrZero(nMedEqp, Len(GE9->GE9_ITEM))
   oGetGe9:aCols[nMedEqp, nGe9CodCrm] := TMPEQP->GMF_CODCRM
   oGetGe9:aCols[nMedEqp, nGe9NomMed] := TMPEQP->RA_NOME
   oGetGe9:aCols[nMedEqp, nGe9TipAtm] := TMPEQP->GMF_CODATO
   oGetGe9:aCols[nMedEqp, nGe9DesAto] := TMPEQP->GMC_DESATO
   oGetGe9:aCols[nMedEqp, nUsadGE9  ] := .F.
 
   DbSkip()  
  EndDo
  
  oGetGe9:oBrowse:Refresh()
  
  DbSelectArea("TMPEQP")
  DbCloseArea()
 EndIf                           
  
 RestArea(aArea)
 
Return(Nil)


Static Function FS_VldAge()

 Local nQtdInt := 0, nQtdCnt := 0, nColPos := oGetGMJ:oBrowse:nColPos
 Local cHorMax := "", lRet   := .T., aArea := GetArea()
 Local cCodLoc :="", cQuarto := "", dDatAge, cHoraAge :=""
 
 cCodLoc  := SubStr(oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1], 1, At("-", oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1]) - 1)
 cQuarto  := SubStr(oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1], At("-", oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1]) + 1, Len(GMJ->GMJ_QUARTO))
 dDatAge  := oCalSala:dDiaAtu
 cHoraAge := oGetGmj:aCols[oGetGMJ:oBrowse:nAt, oGetGMJ:oBrowse:nColPos]                                
 
 If !lRemaneja
  M->GMJ_CODLOC := SubStr(oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1], 1, At("-", oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1]) - 1)
  M->GMJ_QUARTO := SubStr(oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1], At("-", oGetGMJ:aCols[oGetGMJ:oBrowse:nAt, 1]) + 1, Len(GMJ->GMJ_QUARTO))
  M->GMJ_DATAGE := oCalSala:dDiaAtu
  M->GMJ_HORAGE := oGetGmj:aCols[oGetGMJ:oBrowse:nAt, oGetGMJ:oBrowse:nColPos]
 EndIf
   
 DbSelectArea("GMJ")
 DbSetOrder(4) // GMJ_FILIAL + GMJ_FILAGE + GMJ_CODLOC + GMJ_QUARTO + GMJ_DATAGE + GMJ_HORAGE + GMJ_STATUS
 DbSeek(xFilial("GMJ") + M->GMJ_FILAGE + cCodLoc + cQuarto + DTOS(dDatAge) + cHoraAge)

 DbSelectArea("GMD")
 DbSetOrder(1) // GMD_FILIAL + GMD_CODDIS              
 DbSeek(xFilial("GMD") + GMJ->GMJ_CODDIS)

 nQtdInt := HS_HTOM(M->GMJ_TEMPRO) / HS_HTOM(GMD->GMD_INTMAR)

 DbSelectArea("GMJ")

 cHorMax := HS_TotHoras(oGetGmj:aCols[oGetGMJ:oBrowse:nAt, nColPos], M->GMJ_TEMPRO)

 While !Eof() .And. GMJ->GMJ_FILAGE == M->GMJ_FILAGE .And. GMJ->GMJ_CODLOC == cCodLoc .And. GMJ->GMJ_QUARTO == cQuarto .And. ;
                    GMJ->GMJ_DATAGE == dDatAge .And. GMJ->GMJ_HORAGE >= cHoraAge .And. GMJ->GMJ_HORAGE  < cHorMax .And. lRet

  If lRet := GMJ->GMJ_STATUS == "0" .And. oGetGmj:aCols[oGetGMJ:oBrowse:nAt, nColPos] == GMJ->GMJ_HORAGE
   nQtdCnt++
  EndIf 

  nColPos += 2

  DbSkip()
 EndDo

 If !(lRet := nQtdCnt == nQtdInt)
  HS_MsgInf(STR0061 + M->GMJ_TEMPRO + "]", STR0033, STR0075) //"Intervalo insuficiente para agendar uma cirurgia com duração de ["###"Atenção"###"Busca equipe médica e inclui na cirurgia."
 EndIf

 RestArea(aArea)
                                             	
Return(lRet)


Static Function FS_BCodAge(cCodAge)

 Local aArea    := GetArea()         
 Local aRCodAge := {}
 
 DbSelectArea("GMJ")
 DbSetOrder(8) // GMJ_FILIAL + GMJ_SEQAGE + GMJ_CODAGE
 DbSeek(xFilial("GMJ") + cCodAge)
 
 While !Eof() .And. GMJ->GMJ_FILIAL == xFilial("GMJ") .And. GMJ->GMJ_SEQAGE == cCodAge
 
  aAdd(aRCodAge, GMJ->GMJ_CODAGE)
    
  DbSkip()
  
 EndDo

 RestArea(aArea)
 
Return(aRCodAge)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_RetIn  ºAutor  ³Luiz Pereira S. Jr. º Data ³  20/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna todos os itens de alguma coluna de um aCols em uma  º±±
±±º          ³string que sera usada com o "IN" de uma consulta.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nContItens - Retorna a quantidade de itens do aCols        º±±
±±º          ³ aCols - Vetor aCols que sera verificado                    º±±
±±º          ³ nHeader - Numero de Colunas no aHeader                     º±±
±±º          ³ nPos - Coluna que sera verificada pela rotina              º±±
±±º          ³ nAt - Linha em que se encontra o foco                      º±±
±±º          ³ cChamada - Indica de onde a rotina foi chamada             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_RetIn(nContItens, aCols, nHeader, nPos, nAt, cChamada)

 Local nFor := 0
 Local cItens     := ""
 
 Default cChamada := ""
 Default nAt      := 0
 
 nContItens := 0
 
 If !Empty(aCols[1, nPos])
 
  For nFor := 1 To Len(aCols)
   If !aCols[nFor, nHeader + 1] .And. IIf(cChamada == "Pos", nAt <> nFor, .T.)
    If !Empty(cItens)
     cItens += "/"
    EndIf
    If nAt == nFor .And. AllTrim(cChamada) == "Vld"
     cItens += &(ReadVar())
    Else
     cItens += aCols[nFor, nPos]
    EndIf
    nContItens++
   EndIf
  Next
  
 EndIf

Return(cItens)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_BEqpAgeºAutor  ³Luiz Pereira S. Jr. º Data ³  27/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a montagem da getdados de equipamentos e validacao de   º±±
±±º          ³disponibilidade dos equipamentos                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lOk - Indica se a rotina foi chamada do botao OK           º±±
±±º          ³ lValid - Indica se a rotina foi chama                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_BEqpAge(cChamada)

 Local cSqlEqp  := "", lRet := .T., nQtdEqp := 0, nEqpAge := 0, aArea := GetArea()
 Local cCodCCu  := HS_IniPadr("GCS", 1, M->GMJ_CODLOC, "GCS_CODCCU",, .F.)
 Local cDatHorI := DToS(M->GMJ_DATAGE) + M->GMJ_HORAGE
 Local cHoraFi  := HS_TotHoras(M->GMJ_HORAGE, M->GMJ_TEMPRO)
 Local cDatHorF := DToS(M->GMJ_DATAGE) + cHoraFi
 Local nUsadGET := Len(oGetGET:aHeader) + 1
 Local nItens   := 0, cEqptoMed := "", cGeaProc := "", cCodPro := ""
 Local nFor     := 0, nContEqp  := 0
 Local aGetAux  := {}, aCpoIni := {}, aCpoFim := {}
 Local cEIndisp := ""
 Local cAliasOld := Alias()
 //Local aCGetOld := aClone(oGetGET:aCols)

 Default cChamada := ""

 If Empty(aAgeGrv)
  If Alltrim(cChamada) == "Ok"
   HS_MsgInf(STR0077, STR0033, STR0001) // "Escolha o horário para agendamento."###"Atenção"###"Agenda Cirúgica"
   Return(.F.) 
  ElseIf Alltrim(cChamada) == "Vld"
   Return(.T.) 
  EndIf
  Return(.F.)
 EndIf

 If GMJ->(FieldPos("GMJ_USAEQP")) > 0
  If M->GMJ_USAEQP == "0" // Caso nao utiliza equipamentos nao precisa se preocupar com
   RestArea(aArea)        // a disponibilidade do equipamento. 
   Return(.T.)            
  EndIf
 EndIf
 
 If !lTransfer .And. !lRemaneja
  cEqptoMed := HS_RetIn(@nItens, oGetGMR:aCols, Len(oGetGMR:aHeader), nGmrCodGrp, oGetGMR:nAt, cChamada)
 
  If nItens >1
   cEqptoMed := HS_InSql(cEqptoMed, Len(GMR->GMR_CODGRP))
  ElseIf !Empty(cEqptoMed)
   cEqptoMed := "'" + cEqptoMed + "'"
  EndIf
  
  nItens   := 0
  
  cGeaProc := HS_RetIn(@nItens, oGetGEA:aCols, Len(oGetGEA:aHeader), nGeaCodPro, oGetGMR:nAt, cChamada)
  
  If nItens > 1
   cGeaProc := HS_InSql(cGeaProc, Len(GFA->GFA_CODPRO))
  ElseIf !Empty(cGeaProc)
   cGeaProc := "'" + cGeaProc + "'"
  EndIf
  
  cCodPro := IIF(!Empty(cGeaProc), cGeaProc + ",", "") + "'" + M->GMJ_CODPRO + "'"
  
  // Verifica quantos equipamentos o procedimento precisa para ser executado.
  cSqlEqp := "SELECT COUNT(*) NQTDEQP FROM " + RetSqlName("GFA") + " WHERE GFA_FILIAL = '" + xFilial("GFA") + "' AND D_E_L_E_T_ <> '*' AND GFA_CODPRO IN (" + cCodPro + ") AND GFA_CODGRP <> '" + Space(Len(GFA->GFA_CODGRP)) + "'"
  If !Empty(AllTrim(cEqptoMed))
   cSqlEqp += " AND GFA_CODGRP NOT IN (" + cEqptoMed + ") " // DESCONSIDERA EQUIPAMENTOS DO MEDICO
  EndIf
  
  cSqlEqp := ChangeQuery(cSqlEqp)
  
  DbUseArea(.T., "TOPCONN", TcGenQry(,, cSqlEqp), "TMPEQP", .F., .F.)
  
  nQtdEqp := TMPEQP->NQTDEQP
  
  DbCloseArea()
  
  DbSelectArea(cAliasOld)
  
  // Procura equipamentos disponiveis
  cSqlEqp := "SELECT GFA.GFA_CODGRP, GFA.GFA_CODPRO, MIN(GF9.GF9_TEMPOA) GF9_TEMPOA, MIN(GER.GER_CODEQP) GER_CODEQP "
  cSqlEqp += "FROM " + RetSqlName("GFA") + " GFA "
  cSqlEqp += "JOIN " + RetSqlName("GF9") + " GF9 ON GF9.GF9_FILIAL = '" + xFilial("GF9") + "' AND GF9.D_E_L_E_T_ <> '*' AND GF9.GF9_CODGRP = GFA.GFA_CODGRP "
  cSqlEqp += "JOIN " + RetSqlName("GER") + " GER ON GER.GER_FILIAL = '" + xFilial("GER") + "' AND GER.D_E_L_E_T_ <> '*' AND GER.GER_CODGRP = GFA.GFA_CODGRP "
  cSqlEqp += "JOIN " + RetSqlName("ST9") + " ST9 ON ST9.T9_FILIAL = '" + xFilial("ST9") + "' AND ST9.D_E_L_E_T_ <> '*' AND ST9.T9_CODBEM = GER.GER_CODEQP AND ST9.T9_SITBEM = 'A' "
  If lEqpCCusto
   cSqlEqp +=       "AND ST9.T9_CCUSTO = '" + cCodCCu + "' "
  EndIf
  cSqlEqp += "WHERE GFA.GFA_FILIAL = '" + xFilial("GFA") + "' AND GFA.D_E_L_E_T_ <> '*' AND GFA.GFA_CODPRO IN (" + cCodPro + ") "
  If !Empty(AllTrim(cEqptoMed))
	  cSqlEqp += " AND GFA.GFA_CODGRP NOT IN (" + cEqptoMed + ") " // DESCONSIDERA EQUIPAMENTO DO MEDICO
	 EndIf          
	 cSqlEqp += " AND GER.GER_CODEQP NOT IN (SELECT GET.GET_CODEQP FROM " + RetSqlName("GET") + " GET "
	 cSqlEqp +=                             "WHERE GET.GET_FILIAL = '" + xFilial("GET") + "' AND GET.D_E_L_E_T_ <> '*' AND "
	 cSqlEqp +=                             "GET.GET_CODGRP = GER.GER_CODGRP AND GET.GET_CODEQP = GER.GER_CODEQP AND GET.GET_CODAGE <>	'" + M->GMJ_CODAGE + "' AND "
	 cSqlEqp +=	                            "(GET.GET_DATAGE||GET.GET_HORAGE < '" + cDatHorF + "' AND GET.GET_DATFIN||GET.GET_HORAFI > '" + cDatHorI + "')) "
  cSqlEqp += " AND GER.GER_CODEQP NOT IN (SELECT STJ.TJ_CODBEM FROM " + RetSqlName("STJ") + " STJ "
  cSqlEqp +=                             "WHERE STJ.TJ_FILIAL = '" + xFilial("STJ") + "' AND STJ.D_E_L_E_T_ <> '*' AND STJ.TJ_CODBEM = GER.GER_CODEQP AND "
	 cSqlEqp +=                             "STJ.TJ_SITUACA = 'P' AND STJ.TJ_TERMINO = 'N' AND STJ.TJ_TIPOOS = 'B' AND "
	 cSqlEqp +=	                            "(STJ.TJ_DTMPINI||STJ.TJ_HOMPINI < '" + cDatHorF + "' AND STJ.TJ_DTMPFIM||STJ.TJ_HOMPFIM > '" + cDatHorI + "')) "
	 cSqlEqp += "GROUP BY GFA.GFA_CODGRP, GFA.GFA_CODPRO "
	 cSqlEqp += "ORDER BY GFA.GFA_CODPRO
  
	 cSqlEqp := ChangeQuery(cSqlEqp)
  
  DbUseArea(.T., "TOPCONN", TcGenQry(,, cSqlEqp), "TMPEQP", .F., .F.)
 
  DbSelectArea("TMPEQP")
    
  If Len(oGetGet:aCols) == 1 .And. Empty(oGetGET:aCols[1, nGetCodEqp])
   oGetGet:aCols := {}
  EndIf 
  
  nContEqp := 0 
  
  While !Eof()                               
   
   nContEqp++
                           
   If (nEqpAge := aScan(oGetGET:aCols, {| aVet | aVet[nGetCodGrp] == TMPEQP->GFA_CODGRP})) == 0
    oGetGET:AddLine(.F., .F.)
    oGetGET:lNewLine := .F.
    nEqpAge := Len(oGetGET:aCols)
   EndIf
   
   aCpoIni := HS_CALCDAT(M->GMJ_DATAGE, M->GMJ_HORAGE, "-",  TMPEQP->GF9_TEMPOA)   
   aCpoFim := HS_CALCDAT(M->GMJ_DATAGE, cHoraFi, "+",  TMPEQP->GF9_TEMPOA)
  
   //oGetGET:aCols[nEqpAge, nGetIteAge] := StrZero(nEqpAge, Len(GET->GET_ITEAGE))
   oGetGET:aCols[nEqpAge, nGetCodPro] := TMPEQP->GFA_CODPRO
   oGetGET:aCols[nEqpAge, nGetCodGrp] := TMPEQP->GFA_CODGRP
   oGetGET:aCols[nEqpAge, nGetDesGrp] := HS_IniPadr("GF9", 1, TMPEQP->GFA_CODGRP, "GF9_DESGRP",, .F.)
   oGetGET:aCols[nEqpAge, nGetCodEqp] := TMPEQP->GER_CODEQP
   oGetGET:aCols[nEqpAge, nGetDesEqp] := HS_IniPadr("ST9", 1, TMPEQP->GER_CODEQP, "T9_NOME",, .F.)
   oGetGET:aCols[nEqpAge, nGetDatAge] := aCpoIni[1]
   oGetGET:aCols[nEqpAge, nGetHorAge] := aCpoIni[2]
   oGetGET:aCols[nEqpAge, nGetDatFin] := aCpoFim[1]
   oGetGET:aCols[nEqpAge, nGetHoraFi] := aCpoFim[2]
   oGetGET:aCols[nEqpAge, nUsadGET  ] := .F.
                        
   DbSelectArea("TMPEQP")
   DbSkip()
  EndDo
  
  DbSelectArea("TMPEQP")
  DbCloseArea()
  
  DbSelectArea(cAliasOld)
 EndIf
 
 //Verificar disponibilidade dos equipamentos inseridos manualmente
 cEIndisp := ""
 For nFor := 1 To Len(oGetGET:aCols)
  If !FS_VldDisp("", oGetGET:aCols[nFor, nGetCodEqp])
   cEIndisp += "Eqpto [" + AllTrim(oGetGET:aCols[nFor, nGetCodGrp]) + "/" + AllTrim(oGetGET:aCols[nFor, nGetCodEqp]) + "][" + AllTrim(oGetGET:aCols[nFor, nGetDesGrp]) + "]" + Chr(13) + Chr(10)
   oGetGET:nAt := nFor
   If HS_VldM39("M->GET_CODGRP", .T.)
    cEIndisp += "Trocado por" + Chr(13) + Chr(10)
    cEIndisp += "Eqpto [" + AllTrim(oGetGET:aCols[nFor, nGetCodGrp]) + "/" + AllTrim(oGetGET:aCols[nFor, nGetCodEqp]) + "][" + AllTrim(oGetGET:aCols[nFor, nGetDesGrp]) + "]" + Chr(13) + Chr(10)
   Else
    cEIndisp += "E não existe nenhum outro equipamento disponivel do grupo [" + AllTrim(oGetGET:aCols[nFor, nGetCodGrp]) + "]" + Chr(13) + Chr(10)
    oGetGET:aCols[nFor, nUsadGET] := .T. 
   EndIf
  Else
   oGetGET:aCols[nFor, nUsadGET] := .F. 
  EndIf
 Next 
 
 //If !lTransfer
 // If !(lRet := (nQtdEqp == nContEqp))
 //  HS_MsgInf(STR0062, STR0033, STR0075) //"Não foi encontrada disponibilidade para todos os equipamentos necessários para execução da cirurgia."###"Atenção"###"Busca equipe médica e inclui na cirurgia."
 //  oGetGET:aCols := AClone(aCGetOld)
 // EndIf
  
 //ElseIf !Empty(cEIndisp)
 If !Empty(cEIndisp) .Or. !(lRet := IIf(!lTransfer, nQtdEqp == nContEqp, .T.))
  HS_MsgInf(STR0062 + ":" + Chr(13) + Chr(10) + cEIndisp, STR0033, STR0075) //"Não foi encontrada disponibilidade para todos os equipamentos necessários para execução da cirurgia."###"Atenção"###"Busca equipe médica e inclui na cirurgia."
 EndIf
 
 If Len(oGetGet:aCols) == 0
  oGetGET:AddLine(.F., .F.)
  oGetGET:lNewLine := .F.
 EndIf
 oGetGet:oBrowse:Refresh()
 
 RestArea(aArea)
Return(lRet)


//Faz validacoes para aprovar ou nao o duplo clique no horario....
Static Function FS_VldDbCl(cTmpCodLoc, nOpcM39, lVldTemp) // lVldTemp - Se utilizara validacao do tempo da cirurgia

 Local lRet:=.T.
 Local cSql:= "", cQry := ""
 Local nCirSemana := 0
 Local aArea := GetArea()
 
 Default lVldTemp := .T.
 
 cSql := "SELECT GMJ.GMJ_DATAGE , COUNT(*) NDIASEMANA "
 cSql += "FROM " + RetSqlName("GMJ") + " GMJ "
 cSql += "WHERE GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*' AND GMJ.GMJ_DATAGE = '" + Dtos(oCalSala:dDiaAtu) + "' AND "
 cSql += "GMJ.GMJ_STATUS IN ('1','3') AND GMJ.GMJ_CODLOC = '" + cTmpCodLoc + "' AND GMJ_CODAGE = GMJ_SEQAGE "
 cQry := cSql + "AND GMJ.GMJ_USAUTI = '1' AND GMJ_CODAGE <> '" + M->GMJ_CODAGE + "' "
 cQry += "GROUP BY GMJ.GMJ_DATAGE"
 cSql += "GROUP BY GMJ.GMJ_DATAGE"
 
 If nOpcM39 == 2 .Or. (nOpcM39 == 4 .And. GMJ->GMJ_DATAGE <> oCalSala:dDiaAtu)
  lRet:=HS_VldM39("M->GMJ_REGGER", .T.)
 EndIf
 If Empty(M->GMJ_TEMPRO) .And. lRet .And. !lRemaneja .And. lVldTemp
  HS_MsgInf(STR0063, STR0033, STR0001)  //"Por favor preencha o campo 'Duração'"###"Atenção"###"Agenda Cirúrgica"
  lRet := .F.
                                         // SE FOR TRANSFERENCIA PARA DATA DIFERENTE DA ATUAL....
 ElseIf ((!(StrZero(nOpcM39, 2) $ "03/04/05") .And. !lRemaneja ) .Or. (nOpcM39 == 4 .And. GMJ->GMJ_DATAGE <> oCalSala:dDiaAtu);
                                                                   .Or. ( lRemaneja   .And. M->GMJ_DATAGE <> oCalSala:dDiaAtu));
                                                                   .And. lRet
  cSql := ChangeQuery(cSql)  
  DbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "TMPQTD", .F., .F.)

  //valida numero de agendas na data - dia da semana GMN_NUMCIR 
  If (nCirSemana := HS_IniPadr("GMN" , 1 , cTmpCodLoc + AllTrim(Str(DOW(oCalSala:dDiaAtu))) , "GMN_NUMCIR" ,  ,  .F.)) > 0 ;
     .And. TMPQTD->(!Eof()) .And. (TMPQTD->NDIASEMANA >= nCirSemana)
   HS_MsgInf(STR0064 + cTmpCodLoc + "]", STR0033, STR0001) //"O número de agendamentos por dia da semana foi excedido para o setor ["###"Atenção"###"Agenda Cirúgica"
   lRet := .F.
  EndIf      
  TMPQTD->(DbCloseArea())
 EndIf
 
 If lRet
  cQry := ChangeQuery(cQry)
  DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), "TMPUTI", .F., .F.)
  // abaixo compara se a quantidade de UTI's agendadas e maior do que o permitido para o setor...  
  If M->GMJ_USAUTI == '1' .And. TMPUTI->(!Eof()) .And. (TMPUTI->NDIASEMANA >= HS_IniPadr("GCS" , 1 , cTmpCodLoc , "GCS_NUMUTI" ,  ,  .F.));
     .And. lRet
   HS_MsgInf(STR0065 + cTmpCodLoc + "]", STR0033, STR0001) //"O número de agendamentos UTI por dia foi excedido para o setor ["###"Atenção"###"Agenda Cirúgica"
   lRet:=.F.
  EndIf 
  TMPUTI->(DbCloseArea())
 EndIf
 
 If !lRet .And. lRemaneja
  oGetTrab:aCols:={}
  oGetTrab:oBrowse:Refresh()
 EndIf
 
 RestArea(aArea)

Return(lRet)                


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_MontEstºAutor  ³Luiz Pereira S. Jr. º Data ³  31/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função utilizada para montar a getdados que mostra as est   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_MontEst(aCols, aHeader)   
 
 Local aArea  := GetArea()
 Local cSql   := ""
 Local nSetor := 0, nAgendado := 0, nCancelado := 0 , nPos := 0
 Local aAux   := {}, nFor := 0
                                       
 // Para medir o desenpenho dessa rotina basta desabilitar as linhas com o marcador [DESEMP].
 //__cTime := Time() 
 
 If oCalSala:dDiaAtu < dDataBase
  oCalSala:dDiaAtu := dDataBase
  oCalSala:Refresh()
 EndIf
  
 aCols   := {}
 //aHeader := {}
	           
	If Len(aHeader) == 0           
 	Aadd(aHeader, {"Setor", "cSetor" , "@!", 23, 0, ".F." ,"" ,"C", "xxx", "V","" , ""})
	 nSetor := 1//nUsado++  
 
  Aadd(aHeader, { "Agendado","cAgenda" , "", 6, 0, ".F." ,"" ,"N", "xxx", "V","" , "" } )
	 nAgendado := 2//nUsado++
	
	 Aadd(aHeader, {"Cancelado","cCancela", "", 6, 0,".F.",""	, "N", "xxx", "V" ,"" , ""})
	 nCancelado := 3//nUsado++
	EndIf 
	
	cSql:= "SELECT GMJ.GMJ_CODLOC, GCS.GCS_NOMLOC, COUNT(*) SOMA "
 cSql+= "FROM " + RetSqlName("GMJ") + " GMJ "
 cSql+= "LEFT JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' "
 cSql+=                                 "AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GMJ.GMJ_CODLOC "
 cSql+= "WHERE GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + " ' AND GMJ.D_E_L_E_T_ <> '*' AND "
 cSql+=       "GMJ.GMJ_DATAGE = '" + DTOS(oCalSala:dDiaAtu) + "' AND GMJ.GMJ_STATUS = '1' AND GMJ.GMJ_SEQAGE = GMJ.GMJ_CODAGE "
 cSql+= "GROUP BY GMJ.GMJ_CODLOC, GCS.GCS_NOMLOC"
 
 //cSql :=  ChangeQuery(cSql)

 TCQUERY cSql NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 
 While !Eof()
  AADD(aAux, {QRY->GMJ_CODLOC, QRY->GCS_NOMLOC, QRY->SOMA, 0, })
  DbSkip()
 EndDo
 
 DbSelectArea("QRY")
 DbCloseArea()
 
 cSql := "SELECT GML.GML_CODLOC, GCS.GCS_NOMLOC, COUNT(*) SOMA "
 cSql += "FROM " + RetSqlName("GML") + " GML "
 cSql += "LEFT JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*'  AND GCS.GCS_CODLOC = GML.GML_CODLOC "
 cSql += "WHERE GML.GML_FILIAL = '" + xFilial("GML") + "' AND GML.D_E_L_E_T_ <> '*' AND GML.GML_DATAGE ='" + DTOS(oCalSala:dDiaAtu) + "' AND GML.GML_SEQAGE = GML.GML_CODAGE "
 cSql += "GROUP BY GML.GML_CODLOC, GCS.GCS_NOMLOC "
 
 //cSql :=  ChangeQuery(cSql)

 TCQUERY cSql NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()   
 
 While !Eof()
  nPos := aScan(aAux, { |x| x[1]== QRY->GML_CODLOC})
  If nPos == 0
   AADD(aAux, {QRY->GML_CODLOC, QRY->GCS_NOMLOC, 0, QRY->SOMA, })
  Else
   aAux[nPos, 4] := QRY->SOMA
  EndIf
  
  DbSkip()
 EndDo

 DbSelectArea("QRY")
 DbCloseArea()
 
 For nFor := 1 To Len(aAux)
  aAdd(aCols, {aAux[nFor, 1] + "-" + aAux[nFor, 2], aAux[nFor, 3], aAux[nFor, 4],.F.}) 
 Next
 
 RestArea(aArea)
 
Return(Nil)


/********************************************************************************************************/
Function HS_VlM39Co(cCpoVld)

 Local lRet := .T.
 
 Default cCpoVld := ReadVar()

 If cCpoVld == "MV_PAR09" .And. !Empty(MV_PAR09) // CRM do medico
  lRet := ExistCpo("GBJ", MV_PAR09, 1)                  
 ElseIf cCpoVld == "MV_PAR02" .And. !Empty(MV_PAR02) // Do Paciente
  lRet := ExistCpo("GBH", MV_PAR02, 1)
 ElseIf cCpoVld == "MV_PAR03" .And. !Empty(MV_PAR03) // Ate Paciente
  lRet := ExistCpo("GBH", MV_PAR03, 1)
 ElseIf cCpoVld == "MV_PAR10" .And. !Empty(MV_PAR10) // Codigo do Procedimento
  lRet := ExistCpo("GA7", MV_PAR10, 1)
 ElseIf cCpoVld == "MV_PAR11" .And. !Empty(MV_PAR11)// Codigo do Plano
  lRet := ExistCpo("GCM", MV_PAR11, 2)
 ElseIf cCpoVld == "MV_PAR12" .And. !Empty(MV_PAR12)  // Codigo do Usuario
  If !Empty(MV_PAR12)
   PswOrder(2)  // Nome do usuario (tam=15)
   If !PswSeek(MV_PAR12, .T.)
    HS_MsgInf(STR0073 + MV_PAR11 + STR0066 , STR0033, STR0001) //"Usuário "###" não encontrado."###"Atenção"###"Agenda Cirúgica"
    lRet := .F.
   Else
		  lRet := .T.
	  EndIf		 
	 Else
		 lRet := .T.
	 EndIf		
 EndIf 
 
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IniPrInºAutor  ³Luiz Pereira S. Jr. º Data ³  22/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada para a funcao de cadastro de pacientes.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HSPAHM39  - Agenda Cirurgica                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function  FS_IniPrIn()

 Local aArea := GetArea()
 
 cAgdNomPac := M->GMJ_NOMPAC 
 cAgdTelPac := M->GMJ_TELPAC
 DbSelectArea("GBH")
 If !Empty(M->GMJ_REGGER)
  DbSetOrder(1) //GBH_FILIAL + GBH_CODPAC
  If DbSeek(xFilial("GBH") + M->GMJ_REGGER)
   HS_A58("GBH", GBH->(Recno()), 5) // 4 - Alteracao
  EndIf
 Else
  Inclui := .T.
  Altera := .F.
  HS_A58("GBH", 0, 2) // 3 - Inclusao
  Altera := .T.
  Inclui := .F.
 EndIf

 If Type("cAgdNomPac") <> "U"
  M->GMJ_NOMPAC := cAgdNomPac
 EndIf

 If Type("cAgdTelPac") <> "U"
  M->GMJ_TELPAC := cAgdTelPac
 EndIf

 If Type("cAgdRegGer") <> "U"
  M->GMJ_REGGER := cAgdRegGer
 EndIf

 If Type("cAgdCodPla") <> "U"
  M->GMJ_CODPLA := cAgdCodPla
  M->GMJ_DESPLA := HS_IniPadr("GCM", 2, M->GMJ_CODPLA, "GCM_DESPLA",, .F.)
 EndIf
  
 If Type("cAgdMatric") <> "U"
  M->GMJ_MATRIC := cAgdMatric
 EndIf
 
 RestArea(aArea)
 
Return()


Function HS_EXTM39(cAliasM39, nRegM39, nOpcM39)

 HS_EXTM24C(GMJ->GMJ_REGGER, "P", nOpcM39)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_PesqEqpºAutor  ³Luiz Pereira S. Jr. º Data ³  03/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Disponibiliza a opcao de pesquisa de equipamentos na reser- º±±
±±º          ³va cirurgica.                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_PesqEqp()

 Local oDlg     := Nil
 Local nPosIni  := 11
 Local aSize    := {}, aObjects  := {}, aInfo  :={}, aPobjs :={}
 Local aHGMJ    := {}, aCGMJ     := {}, nUGMJ  := 0
 Local cSetorDe := "", cSetorAte := "", dDataDe := CTOD("  /  /  "), dDataAte := CTOD("  /  /  ")
 Local cEqpDe   := "", cEqpAte   := "", cGrpDe  := "", cGrpAte := ""
 Local cOrderBy := "", cGroupBy  := "", cLstCpo := ""
 Local cPerg    := "HSM39E" 
 Local oGetGMJ 

 cGcsTipLoc := "4"
 If !Pergunte(cPerg, .T.)
  cGcsTipLoc := "6"
  Return()
 EndIf
 cGcsTipLoc := "6"
 
 cSetorDe  := MV_PAR01
 cSetorAte := MV_PAR02
 dDataDe   := MV_PAR03 
 dDataAte  := MV_PAR04
 cEqpDe    := MV_PAR05
 cEqpAte   := MV_PAR06
 cGrpDe    := MV_PAR07
 cGrpAte   := MV_PAR08

 aSize := MsAdvSize(.T.)
 aObjects := {}	                           
 
 AAdd(aObjects, { 100, 100, .T., .T. })	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize(aInfo, aObjects, .T.)
 
 cLstCpo  := "GMJ_FILAGE/GMJ_QUARTO/GMJ_DATAGE/GMJ_HORAGE/GMJ_HORAFI/GMJ_REGGER/GMJ_MATRIC/GMJ_NOMPAC/GMJ_CODPRO" + ;
            "/GMJ_DESPRO/GMJ_CODCRM/GMJ_NOMCRM/GMJ_CODPLA/GMJ_DESPLA/GMJ_DATCAD/GMJ_HORCAD/GMJ_CODUSU/GMJ_QUARTO"
 
 cCond  := " GMJ->GMJ_STATUS == '1' AND GMJ->GMJ_SEQAGE == GMJ->GMJ_CODAGE "
 IF !Empty(MV_PAR03) .Or. !Empty(MV_PAR04)
  cCond += " AND GMJ->GMJ_DATAGE >= '" + DTOS(MV_PAR03) + "' AND GMJ->GMJ_DATAGE <= '" + DTOS(MV_PAR04) + "' "
 EndIf
 
 IF !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
  cCond += " AND GMJ->GMJ_CODLOC >= '" + MV_PAR01 + "' AND GMJ->GMJ_CODLOC <= '" + MV_PAR02 + "' "
 EndIf
 
 aJoin :=  {{     " JOIN " + RetSqlName("GET") + " GET ", " " , "GET.GET_FILIAL = '" + xFilial("GET") + "' AND GET.D_E_L_E_T_ <> '*' AND GET.GET_CODAGE = GMJ.GMJ_CODAGE AND GET.GET_CODGRP BETWEEN '" + cGrpDe + "' AND '" + cGrpAte + "' ", " "}} 
 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GF9") + " GF9 ", " " , "GF9.GF9_FILIAL = '" + xFilial("GF9") + "' AND GF9.D_E_L_E_T_ <> '*' AND GF9.GF9_CODGRP = GET.GET_CODGRP ", " "})
 aAdd(aJoin,{     " JOIN " + RetSqlName("GER") + " GER ", " " , "GER.GER_FILIAL = '" + xFilial("GER") + "' AND GER.D_E_L_E_T_ <> '*' AND GER.GER_CODGRP = GF9.GF9_CODGRP AND GER.GER_CODEQP BETWEEN '" + cEqpDe + "' AND '" + cEqpAte + "' ", " "})
 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("ST9") + " ST9 ", " " ,  "ST9.T9_FILIAL = '" + xFilial("ST9") + "' AND ST9.D_E_L_E_T_ <> '*' AND ST9.T9_CODBEM = GER.GER_CODEQP ", " "})

 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GCM") + " GCM ", "GCM.GCM_DESPLA" , "GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GMJ.GMJ_CODPLA ", "GMJ_DESPLA"})
 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GA7") + " GA7 ", "GA7.GA7_DESC"   , "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GMJ.GMJ_CODPRO ", "GMJ_DESPRO"})
 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("SRA") + " SRA ", "SRA.RA_NOME"    , "SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = GMJ.GMJ_CODCRM ", "GMJ_NOMCRM"})
 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GMD") + " GMD ", "GMD.GMD_DESDIS" , "GMD.GMD_FILIAL = '" + xFilial("GMD") + "' AND GMD.D_E_L_E_T_ <> '*' AND GMD.GMD_CODDIS = GMJ.GMJ_CODDIS ", "GMJ_DESDIS"})
 
 cOrderBy  := "GMJ.GMJ_DATAGE, GMJ.GMJ_HORAGE"
 
 cGroupBy  := "GMJ.GMJ_FILAGE, GMJ.GMJ_QUARTO, GMJ.GMJ_DATAGE, GMJ.GMJ_HORAGE, GET.GET_HORAFI, GMJ.GMJ_REGGER, GMJ.GMJ_MATRIC, GMJ.GMJ_NOMPAC, GMJ.GMJ_CODPRO, " + ;
              "GMJ.GMJ_CODCRM, GMJ.GMJ_CODPLA, GMJ.GMJ_DATCAD, GMJ.GMJ_HORCAD, GMJ.GMJ_CODUSU, GMJ.GMJ_QUARTO"
              
 cCpoGrpBy := "GMJ.GMJ_FILAGE, GMJ.GMJ_QUARTO, GMJ.GMJ_DATAGE, GMJ.GMJ_HORAGE, GET.GET_HORAFI GMJ_HORAFI, GMJ.GMJ_REGGER, GMJ.GMJ_MATRIC, GMJ.GMJ_NOMPAC, GMJ.GMJ_CODPRO, " + ;
              "GMJ.GMJ_CODCRM, GMJ.GMJ_CODPLA, GMJ.GMJ_DATCAD, GMJ.GMJ_HORCAD, GMJ.GMJ_CODUSU, GMJ.GMJ_QUARTO, MAX(GCM.GCM_DESPLA) GMJ_DESPLA, MAX(GA7.GA7_DESC) GMJ_DESPRO, MAX(SRA.RA_NOME) GMJ_NOMCRM, MAX(GMD.GMD_DESDIS) GMJ_DESDIS"
 
 HS_BDados("GMJ", @aHGMJ, @aCGMJ, @nUGMJ, 1,, cCond,,, cLstCpo,,,,,,.T.,,, .T.,cCpoGrpBy,cGroupBy,, aJoin,, cOrderBy)
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0019) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL // "&Equipamentos"
  
  oGetGMJ := MsNewGetDados():New(aPobjs[1, 1], aPobjs[1, 2], aPobjs[1, 3], aPobjs[1, 4], 0,,,,,,,,,, oDlg, aHGMJ, aCGMJ)
  oGetGMJ:oBrowse:Align := CONTROL_ALIGN_BOTTOM
  
 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||oDlg:End()}, {||oDlg:End()})
 
Return(.F.)


Static Function FS_IniObs()
                
 If !lRemaneja .And. !lAgendar
  cObsPlano := HS_IniPadr("GA9",1, M->GMJ_CODCON, "GA9_OBSERV",, .F.) 
  cObsProc  := HS_IniPadr("GA7",1, M->GMJ_CODPRO, "GA7_OBSERV",, .F.)
  cObsProf  := HS_IniPadr("GBJ",1, M->GMJ_CODCRM, "GBJ_OBSERV",, .F.)
  
  oObsPlano:Refresh()
  oObsProc:Refresh()
  oObsProf:Refresh()
 EndIf

Return()     


// Valida se o usuario escolheu um novo horario de agendamento
Static Function HS_M39VTrf(nOpcM39, aAgeMar)

 Local lRet := .T.
 
 If nOpcM39 == 4 .And. Empty(aAgeMar)
  HS_MsgInf("Escolha o novo horário para a reserva!", STR0033, STR0001) //"Atenção"###"Agenda Cirúgica"
  lRet := .F.
 EndIf
 
Return(lRet)                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_RelM39 ºAutor  ³Mario Arizono       º Data ³  24/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que mostra as fichas do setor correspondente.        º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_RelM39(cAlias, nReg, nOpc)  
 GDN->(dbSetOrder(1))
 If GDN->(DbSeek(xFilial("GDN") + cGcsCodLoc))
  HSPAHP44(.F., cGcsCodLoc)
 EndIf 
 
Return

Static Function FS_MntAgd(aHeadAgd, aColsAgd, nUsadoAgd, dData)
 
 Local aCposIni    := {"GMJ_FILAGE","GMJ_QUARTO","GMJ_DATAGE","GMJ_HORAGE","GMJ_HORAFI","GMJ_REGGER","GMJ_MATRIC","GMJ_NOMPAC","GMJ_CODPRO", ;
                       "GMJ_DESPRO","GMJ_CODCRM","GMJ_NOMCRM","GMJ_CODPLA","GMJ_DESPLA","GMJ_DATCAD","GMJ_HORCAD","GMJ_CODUSU"}
                    
 Local cFiltro     := " GMJ->GMJ_STATUS == '1' .AND. GMJ->GMJ_CODAGE == GMJ->GMJ_SEQAGE .AND. GMJ->GMJ_FILIAL == '"+xFilial("GMJ")+"' "
 
 Local aJoin       := {}
 
 Default dData     := dDatabase

 aHeadAgd  := {}
 aColsAgd  := {}
 nUsadoAgd := 0
 
 cFiltro += " .AND. GMJ->GMJ_DATAGE == '"+DtoS(dData)+"' "

 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GCM") + " GCM ", "GCM.GCM_DESPLA" , "GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GMJ_CODPLA ", "GMJ_DESPLA"})
 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GA7") + " GA7 ", "GA7.GA7_DESC"   , "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GMJ_CODPRO ", "GMJ_DESPRO"})
 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("SRA") + " SRA ", "SRA.RA_NOME"    , "SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = GMJ_CODCRM ", "GMJ_NOMCRM"})
 
 HS_BDados("GMJ", @aHeadAgd, @aColsAgd, @nUsadoAgd, 1,, cFiltro,,,"/",,,,,,.T.,,,,,, aCposIni, aJoin)  
 
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TudoOK  ºAutor  ³Giuvany Ribeiro    º Data ³  12/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o Mat/Med já Foi Autorizado                     º±±
±±º          ³não permitindo a Alteração da Quantidade no Agendamento     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function FS_TudoOK(nOpcM39,cSeqAge,aColsGEB) 

Local lRet :=.T. 
Local cSql := ""                                                                 
Local nFor := 0

If nOpcM39 <> 5
	Return(lRet)
Endif
 
cSql :=" SELECT GE2_STATUS,GE2_CODDES,GE2_QTDSOL  FROM  " + RetSQLName("GE2") + " GE2
cSql +=" JOIN " + RetSqlName("GNX") + " GNX ON GNX.GNX_FILIAL = '" + xFilial("GNX") + "' AND GNX.D_E_L_E_T_ <> '*'  AND GNX.GNX_CODSOL = GE2.GE2_CODSOL "
cSql +=" WHERE GE2.GE2_FILIAL = '" + xFilial("GE2") + "' AND GE2.D_E_L_E_T_ <> '*' AND GE2_STATUS <> '0' "
cSql +=" AND GNX_CODAGE='"+cSeqAge+"'
cSql := ChangeQuery(cSql)    
 
TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop()  
  
While !Eof()                                                                                
	For nFor := 1 to Len(aColsGEB)
        If aColsGEB[nFor][2]== QRY->GE2_CODDES .and. aColsGEB[nFor][4] <> QRY->GE2_QTDSOL
        	HS_MsgInf(STR0095, STR0033, STR0001)	
			lRet:=.F.	
		Endif
	Next nFor	
    DbSkip()
EndDo
  
QRY->(dbCloseArea())                                                        

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 10/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{OemToAnsi(STR0037), "AxPesqui"       , 0, 1, 0, nil},; //"Pesquisar"
                     {OemToAnsi(STR0002), "HS_M39Atu"      , 0, 3, 0, nil},; //"Agendar"
                     {OemToAnsi(STR0003), "HS_M39Atu"      , 0, 4, 0, nil},; //"Cancelar"
                     {OemToAnsi(STR0004), "HS_M39Atu"      , 0, 4, 0, nil},; //"Transferir"
                     {OemToAnsi(STR0005), "HS_M39Atu"      , 0, 4, 0, nil},; //"Alterar"
                     {OemToAnsi(STR0006), "HS_EXTM39"      , 0, 2, 0, nil},; //"Extrato"
                     {OemToAnsi(STR0007), "HS_ConsAge('C')", 0, 2, 0, nil},; //"Consultar"
                     {OemToAnsi(STR0067), "HS_M39Atu"      , 0, 4, 0, nil},; //"Realocação"
                     {OemToAnsi(STR0068), "HS_M39Atu"      , 0, 4, 0, nil},; //"Pré-Internação"
                     {OemToAnsi(STR0008), "HS_M39Leg"      , 0, 3, 0, nil},; //"Legenda"
                     {OemToAnsi(STR0019), "HS_PesqEqp"     , 0, 3, 0, nil},; //"Equipamentos"
                     {OemtoAnsi(STR0087), "HS_RelM39"      , 0, 2, 0, nil}}  //"Docs/Relat."
Return(aRotina)
