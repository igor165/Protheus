#INCLUDE "HSPFUM24.ch"
#Include "Protheus.CH"
#INCLUDE "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_CposGcy ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina define pelo nOpc quais campos aparecerão no atendimento³±±
±±³          ³quais setão Obrigatórios, Alteraréis 1e se poderá alterar os   ³±±
±±³          ³campos referente a alta.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: nOpc do Atendimento                                    ³±±
±±³          ³ExpA2: Array com os campos Obrigatórios, deve ser passado     ³±±
±±³          ³       por referência.                                        ³±±
±±³          ³ExpA3: Array com os campos que aparecerão na enchoice,        ³±±
±±³          ³       deve ser passado por referência.                       ³±±
±±³          ³ExpA4: Array com os campos que serão Alteraveis na enchoice,  ³±±
±±³          ³        deve ser passado por referência.                      ³±±
±±³          ³ExpL5: Altera campos da alta                             (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_MntAbq,HS_GarM24,HS_RecM24                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_CposGcy(nOpcM24, aCposObr, aCposGcy, aCposAlt, lAlteraAlta)
Local aCposIgn := {}, aCposVis := {}


Default lAlteraAlta := .F.

If     cGcyAtendi == "0" // Internação
	If !lAlteraAlta
		aCposIgn := {"GCY_DATALT", "GCY_HORALT", "GCY_DATSAI", "GCY_HORSAI", "GCY_TPALTA", "GCY_DESALT", "GCY_CIDALT", ;
              	"GCY_DESCID", "GCY_CIDCMP", "GCY_DESCMP", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", ;
               "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", "GCY_AUTJUD", "GCY_RG    ", "GCY_ORGEMI", "GCY_UFEMIS",;
               "GCY_GESTAC","GCY_TRAMAT","GCY_COMPUE","GCY_OBIMUL", "GCY_CIDCO1", "GCY_DESCC1","GCY_CIDCO2", "GCY_DESCC2"}
  		If aRotina[nOpcM24, 3] <> 7 .AND. FUNNAME() # "HSPAHM30" .AND. HS_EXISDIC({{"C", "GCY_CLISEC"}},.F.) // Despesa Posto
  			AADD(aCposIgn,"GCY_CLISEC")
			AADD(aCposIgn,"GCY_DSCLIS")
			AADD(aCposIgn,"GCY_DTCLIS")
		EndIf 		
	Else
		aCposIgn := {"GCY_DATSAI", "GCY_HORSAI", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", ;
              	"GCY_AUTJUD", "GCY_RG    ", "GCY_ORGEMI", "GCY_UFEMIS", "GCY_GESTAC","GCY_TRAMAT","GCY_COMPUE","GCY_OBIMUL"}
	EndIf
	
	If aRotina[nOpcM24, 3] == 10 // 10-Transferencia do setor ambulatorial para o setor de internação
		aCposVis := {"GCY_DTNASC", "GCY_SEXO  ", "GCY_REGGER", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", "GCY_AUTJUD", "GCY_RG    ", "GCY_ORGEMI", "GCY_UFEMIS"}
	ElseIf aRotina[nOpcM24, 3] == 04 .and. FUNNAME() # "HSPAHM35" // 04-Alteração
		aCposVis := {"GCY_DTNASC", "GCY_SEXO  ", "GCY_REGGER", "GCY_QUAINT", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", "GCY_AUTJUD", "GCY_RG    ", "GCY_ORGEMI", "GCY_UFEMIS"}
	ElseIf aRotina[nOpcM24, 3] == 7 .AND. FUNNAME() == "HSPAHM30" .AND. HS_EXISDIC({{"C", "GCY_CLISEC"}},.F.)// Despesa Posto Enfermagem
		aCposVis := {"GCY_CLISEC","GCY_DSCLIS","GCY_DTCLIS"}
		aCposAlt := {"GCY_CLISEC","GCY_DTCLIS"}		
	ElseIf  aRotina[nOpcM24, 3] == 04 .and. FUNNAME() == "HSPAHM35" .AND. HS_EXISDIC({{"C", "GT6_REGGER"}},.F.)// Quando for Movimentação pela  Lista de Espera   
   	  	aCposVis := {"GCY_REGGER","GCY_CIDINT","GCY_CIDCMI","GCY_CDESTI","GCY_ACOMPA","GCY_NMACOM","GCY_CRMALT","GCY_OBSALT","GCY_OBTDOC","GCY_ABORTO","GCY_ACITRA","GCY_CDPREV","GCY_CNASUS","GCY_MATRIC","GCY_DTNASC",;
   	  				 "GCY_SEXO  ", "GCY_CODCRM", "GCY_CODCLI", "GCY_CLISEC", "GCY_DTCLIS", "GCY_ORIPAC", "GCY_CARATE", "GCY_REGIME", "GCY_CODRES", "GCY_DATALT"}  // esconde
   	  	aCposAlt := {"GCY_QUAINT", "GCY_CODLOC"}
   	  	If Type("lAltCodLoc") == "L"
   	  		lAltCodLoc := .T.
   	  	EndIf
	EndIf
	
	aCposObr := {"GCY_QUAINT", "GCY_REGIME"}
	
ElseIf cGcyAtendi $ "14" // Ambulatorial
	If !lAlteraAlta
		aCposIgn := {"GCY_QUAINT", "GCY_LEIINT", "GCY_DATALT", "GCY_HORALT", "GCY_TPALTA", ;
		"GCY_DESALT", "GCY_CIDALT", "GCY_DESCID", "GCY_CIDCMP", "GCY_DESCMP", 	"GCY_CODLOC", "GCY_NOMLOC", ;
	 "GCY_DATSAI", "GCY_HORSAI", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", ;
		"GCY_AUTJUD", "GCY_RG    ", "GCY_ORGEMI", "GCY_UFEMIS", "GCY_REGIME", "GCY_GESTAC","GCY_TRAMAT","GCY_COMPUE","GCY_OBIMUL",;
		"GCY_CIDCO1", "GCY_DESCC1", "GCY_CIDCO2", "GCY_DESCC2","GCY_CLISEC","GCY_DSCLIS","GCY_DTCLIS"}
		If aRotina[nOpcM24, 3] == 7
	  aCposAlt := {"GCY_CIDINT", "GCY_CIDCMI"}
	 EndIf 		
	Else
		aCposIgn := {"GCY_QUAINT", "GCY_LEIINT", "GCY_CODLOC", "GCY_NOMLOC", "GCY_DATSAI", ;
	 "GCY_HORSAI", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", ;
		"GCY_AUTJUD", "GCY_RG    ", "GCY_ORGEMI", "GCY_UFEMIS", "GCY_REGIME", "GCY_GESTAC","GCY_TRAMAT","GCY_COMPUE","GCY_OBIMUL"}
	EndIf
	
	aCposVis := IIf(StrZero(nOpcM24, 2) $ "03/04", {"GCY_DTNASC", "GCY_SEXO  ", "GCY_REGGER", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", "GCY_AUTJUD", "GCY_RG    ", "GCY_ORGEMI", "GCY_UFEMIS"}, {}) // 3-Recepcao da Agenda Ambulatorial ou 4-Alteração
	
ElseIf cGcyAtendi == "2" // Pronto Atendimento
	If !lAlteraAlta
		aCposIgn := {"GCY_DATALT", "GCY_HORALT", "GCY_TPALTA", "GCY_DATSAI", "GCY_HORSAI", ;
		"GCY_DESALT", "GCY_CIDALT", "GCY_DESCID", "GCY_CIDCMP", "GCY_DESCMP", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", ;
	 "GCY_AUTJUD", "GCY_RG    ", "GCY_ORGEMI", "GCY_UFEMIS", "GCY_REGIME", "GCY_GESTAC","GCY_TRAMAT","GCY_COMPUE","GCY_OBIMUL",;
	 "GCY_CIDCO1", "GCY_DESCC1", "GCY_CIDCO2", "GCY_DESCC2","GCY_CLISEC","GCY_DSCLIS","GCY_DTCLIS"}
	
	 If aRotina[nOpcM24, 3] == 7
	  aCposAlt := {"GCY_CIDINT", "GCY_CIDCMI"}
	 Endif 
	Else
		aCposIgn := {"GCY_DATSAI", "GCY_HORSAI", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", ;
             		"GCY_AUTJUD", "GCY_RG    ", "GCY_ORGEMI", "GCY_UFEMIS", "GCY_REGIME", "GCY_GESTAC","GCY_TRAMAT","GCY_COMPUE","GCY_OBIMUL"}
	EndIf
	
	aCposVis := IIf(aRotina[nOpcM24, 3] == 4, {"GCY_DTNASC", "GCY_SEXO  ", "GCY_REGGER", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", "GCY_AUTJUD", "GCY_RG    ", "GCY_ORGEMI", "GCY_UFEMIS"}, {}) // 4-Alteração
	
ElseIf cGcyAtendi == "3" // Atendimento Doacao
 If !lAlteraAlta
		aCposIgn := {"GCY_CARATE", "GCY_DCARAT", "GCY_QUAINT", "GCY_LEIINT", "GCY_DATALT", "GCY_HORALT", "GCY_TPALTA", ;
		"GCY_DESALT", "GCY_CIDALT", "GCY_DESCID", "GCY_CIDCMP", "GCY_DESCMP", "GCY_ACITRA", "GCY_CODEMP", ;
		"GCY_EMPRES", "GCY_CODLOC", "GCY_NOMLOC", "GCY_DATSAI", "GCY_HORSAI", "GCY_CODRES", "GCY_CIDINT", "GCY_CIDCMT", ;
		"GCY_CDESTI", "GCY_ACOMPA", "GCY_NMACOM", "GCY_CRMALT", "GCY_OBSALT", "GCY_OBTDOC", "GCY_VISQT ", "GCY_ACOQT ", ;
		"GCY_CODUSU", "GCY_DCIDIN", "GCY_DCIDCI", "GCY_DDESTI", "GCY_MEDALT", "GCY_NOMRES", "GCY_CIDCMI", "GCY_VOTOEX", ;
		"GCY_CODCLI", "GCY_DESCLI", "GCY_REGIME", "GCY_GESTAC","GCY_TRAMAT","GCY_COMPUE","GCY_OBIMUL",;
		"GCY_CIDCO1", "GCY_DESCC1", "GCY_CIDCO2", "GCY_DESCC2","GCY_CLISEC","GCY_DSCLIS","GCY_DTCLIS"}
	Else
		aCposIgn := {"GCY_CARATE", "GCY_DCARAT", "GCY_QUAINT", "GCY_LEIINT", "GCY_ACITRA", "GCY_CODEMP", "GCY_EMPRES", ;
		"GCY_CODLOC", "GCY_NOMLOC", "GCY_DATSAI", "GCY_HORSAI", "GCY_CODRES", "GCY_CIDINT", "GCY_CIDCMT", ;
		"GCY_CDESTI", "GCY_ACOMPA", "GCY_NMACOM", "GCY_CRMALT", "GCY_OBSALT", "GCY_OBTDOC", "GCY_VISQT ", "GCY_ACOQT ", ;
		"GCY_CODUSU", "GCY_DCIDIN", "GCY_DCIDCI", "GCY_DDESTI", "GCY_MEDALT", "GCY_NOMRES", "GCY_CIDCMI", "GCY_VOTOEX", ;
		"GCY_CODCLI", "GCY_DESCLI", "GCY_REGIME", "GCY_GESTAC","GCY_TRAMAT","GCY_COMPUE","GCY_OBIMUL","GCY_CLISEC","GCY_DSCLIS","GCY_DTCLIS"}
	EndIf
	
	aCposVis := IIf(StrZero(nOpcM24, 2) $ "03/04", {"GCY_DTNASC", "GCY_SEXO  ", "GCY_REGGER", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", "GCY_AUTJUD", "GCY_RG    ", "GCY_ORGEMI", "GCY_UFEMIS"}, {}) // 3-Recepcao da Agenda Ambulatorial ou 4-Alteração

EndIf

If lAlteraAlta
	aCposAlt := {"GCY_DATALT", "GCY_HORALT", "GCY_TPALTA", "GCY_CIDALT", "GCY_CIDCMP", "GCY_CIDCO1", "GCY_CIDCO2", "GCY_CIDINT", "GCY_CRMALT", "GCY_OBSALT", "GCY_OBTDOC", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", ;
             	"GCY_AUTJUD"}
EndIf

If aRotina[nOpcM24, 3] # 10 // 10-Transferencia do setor ambulatorial para o setor de internação
	aAdd(aCposIgn, "GCY_LOCATE")
	aAdd(aCposIgn, "GCY_NLATEN")
EndIf

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("GCY")
While !Eof() .And. SX3->X3_ARQUIVO == "GCY"
	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. aScan(aCposIgn, SX3->X3_CAMPO) == 0
		aAdd(aCposGcy, SX3->X3_CAMPO)
		If aScan(aCposVis, SX3->X3_CAMPO) == 0 .And. IIF(cGcyAtendi <> "3", aRotina[nOpcM24, 3] # 7, cGcyAtendi == "3") // 7-Guias
			aAdd(aCposAlt, SX3->X3_CAMPO)
		EndIf
	Endif
	
	If aRotina[nOpcM24, 3] == 10 // 10-Transferencia do setor ambulatorial para o setor de internação
		If SX3->X3_CAMPO == "GCY_REGATE"
			Inclui := .T.
			&("M->" + SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
			Inclui := .F.
		Else
			&("M->" + SX3->X3_CAMPO) := IIf(SX3->X3_CONTEXT == "V", CriaVar(SX3->X3_CAMPO), GCY->(FieldGet(GCY->(FieldPos(SX3->X3_CAMPO)))))
		EndIf
	Else
		If aRotina[nOpcM24, 4] == 3
			&("M->" + SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
		Else
			&("M->" + SX3->X3_CAMPO) := IIf(SX3->X3_CONTEXT == "V", CriaVar(SX3->X3_CAMPO), GCY->(FieldGet(GCY->(FieldPos(SX3->X3_CAMPO)))))
		EndIf
	EndIf
	
	DbSkip()
End
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_AgeM24 ³ Autor ³Gestão Hospitalar      ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa rotina de agendamento Ambulatorial ou Cirurgico     ³±±
±±³          ³da rotina de Atendimento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPM24AI,HSPM24AA,HSPM24PA,HSPM24AD                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/       
Function HS_AgeM24() // parametro tipo de agenda A=Ambulatorio P=PA
Local cAliasOld := Alias(), aArea := HS_SavArea({{"GCY", 0, 0}}), cOldCodLoc := cGcsCodLoc
Local cTipOld := cGcsTipLoc

Private cGcuCodTpg := Nil
Private aRotina    := {}, Inclui := .T.

aAdd(aRotina,{"", "", 0, 1}) //"Pesquisar"
aAdd(aRotina,{"", "", 0, 3}) //"Agendar"
aAdd(aRotina,{"", "", 0, 4}) //"Cancelar"
aAdd(aRotina,{"", "", 0, 4}) //"Transferir"
aAdd(aRotina,{"", "", 0, 4}) //"Alterar"
aAdd(aRotina,{"", "", 0, 1}) //"Legenda"

cGcsCodLoc := cM24Par01
DbSelectArea("GCS")
DbSetOrder(1)
DbSeek(xFilial("GCS") + cGcsCodLoc)

If cGcyAtendi == "0"
	DbSelectArea("GMJ")
	HS_M39Atu('GMJ', GMJ->(RecNo()), 2)
Else
	DbSelectArea("GM8")
	If GCS->GCS_TIPLOC == "J" 
		cGcsTipLoc := "J"
		HSPM54Atu('GM8', GM8->(RecNo()), 2)	 //Agenda Clinicas
	Else
		HSPM29Atu('GM8', GM8->(RecNo()), 2)
	EndIf
EndIf

MBrChgLoop(.F.)

cGcsCodLoc := cOldCodLoc 
cGcsTipLoc := cTipOld

HS_ResArea(aArea)
DbSelectArea(cAliasOld)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_MdLM24 ³ Autor ³Gestão Hospitalar      ³ Data  ³15.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama rotina para conversao de Apartmento em Enfermaria e     ³±±
±±³          ³vice-versa                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPM24AI                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/       
Function HS_MdLM24()
Private cGflRegra  := ""
Private cGcsCodLoc := ""

If Pergunte("HSPM24", .T.)
	HS_A19MOD(MV_PAR01, MV_PAR02, MV_PAR03)
Endif
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_AltM24 ³ Autor ³Gestão Hospitalar      ³ Data  ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa rotina de alta a partir da rotina de atendimento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPM24AI,HSPM24AA,HSPM24PA,FS_GrvM24                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/       
Function HS_AltM24()
Local cAliasOld := Alias()

Private aRotina := { {"","",0,1},; //"Pesquisar"
                      {"","",0,4},; //"Alta"
                      {"","",0,3},; //"Saida"
                      {"","",0,3},; //"Libera Leito"
                      {"","",0,3},; //"Transferencia"
                      {"","",0,4},; //"Solicitacao"
                      {"","",0,3},; //"Devolucao"
                      {"","",0,3},; //"Cancela Alta"
                      {"","",0,3},; //"Cancela Saida"
                      {"","",0,3},; //"Dieta do Paciente"
                      {"","",0,1} } //"Legenda"

If !Empty(GCY->GCY_TPALTA) 
 If GCY->GCY_TPALTA <> "99"
  HS_MsgInf(STR0024,STR0003,STR0025)//"Paciente ja está de alta...Operacao Cancelada."##"Atencao"##"Movimentação de alta"
  Return(nil)
 Else
 	HS_MsgInf(STR0026,STR0003,STR0025) //"Paciente nao pode receber alta pois o atendimento foi cancelado"##"Atencao"##"Movimentação de alta"
 	Return(Nil)  
 Endif 
Else	
 If !LockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)  
 	HSPVerFiCo("ExecM24",GCY->GCY_REGATE,.T.)
	DbSelectArea(cAliasOld)
 	Return(Nil)
 Else
   HSPGerFiCo("ExecM24",GCY->GCY_REGATE)
 EndIf
    
 DbSelectArea("GAV")
 DbSetOrder(1)
 DbSeek(xFilial("GAV") + GCY->GCY_CODLOC + GCY->GCY_QUAINT + GCY->GCY_LEIINT)

 HS_M30ALT("GAV", GAV->(RecNo()), 2,, .T., GCY->GCY_REGATE, !Empty(GCY->GCY_QUAINT))
	UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.) 
	HSPDelFiCo("ExecM24",GCY->GCY_REGATE)
Endif
DbSelectArea(cAliasOld)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_CAlM24 ³ Autor ³Luiz Pereira S. Jr.    ³ Data  ³31.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa rotina de cancelamento da alta                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPM24AI,HSPM24AA,HSPM24PA                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/       
Function HS_CAlM24()
Local aArea	:= GetArea()
Local lFat	:= .F.
 
Private aRotina := {	{"", "", 0, 1},; //"Pesquisar"
						{"", "", 0, 4},; //"Alta"
						{"", "", 0, 3},; //"Saida"
						{"", "", 0, 3},; //"Libera Leito"
						{"", "", 0, 3},; //"Transferencia"
						{"", "", 0, 4},; //"Solicitacao"
						{"", "", 0, 3},; //"Devolucao"
						{"", "", 0, 3},; //"Cancela Alta"
						{"", "", 0, 3},; //"Cancela Saida"
						{"", "", 0, 3},; //"Dieta do Paciente"
						{"", "", 0, 1} } //"Legenda"
																						
If cGcyAtendi $ "1/2"
	If Hs_ExisDic({{"C", "GCY_ATEDST"}}) 
		If !EMPTY(GCY->GCY_ATEDST) 
			HS_MsgInf(	STR0076 + CHR(10) + ; //"Impossível cancelar a alta pois o paciente já foi transferido para internação."
						STR0077 + " [" + GCY->GCY_ATEDST + "]", STR0003, STR0078) //"Atendimento"###"Atenção"###"Cancela Alta"
			Return(Nil)
		EndIf 
	Else
		Return(Nil)
	EndIf
EndIf 

DbSelectArea("GCZ")
DbSetOrder(2)
DbSeek(xFilial("GCZ") + GCY->GCY_REGATE)

If !LockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
    HSPVerFiCo("ExecM24",GCY->GCY_REGATE,.T.)
    RestArea(aArea)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCY->GCY_REGATE)
EndIf	

While !GCZ->(Eof()) .AND. GCZ->GCZ_REGATE == GCY->GCY_REGATE
	If GCZ->GCZ_STATUS $ ("2/3/4/5/6/7")			// Verifica se tem alguma guia faturada para o atendimento
		lFat := .T.
		Exit
	EndIf
	GCZ->(DbSkip())
End

If lFat		// Se existir alguma guia faturada para o atendimento, o sistema nao deixara cancelar a alta
	HS_MsgInf( STR0097 + CHR(10) + STR0077 + " [" + GCY->GCY_REGATE + "]", STR0003, STR0078 )		// "Impossível cancelar a alta, pois este atendimento já está Faturado."###"Atendimento"###"Atenção"###"Cancela Alta"
	UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCY->GCY_REGATE)
	Return(nil)
EndIf

If Empty(GCY->GCY_QUAINT) 
	HS_GrvAlta(GCY->GCY_REGATE,,,,,, .T.)  
Else
	DbSelectArea("GAV")
	DbSetOrder(1) // GAV_FILIAL+GAV_CODLOC+GAV_QUARTO+GAV_LEITO
	If DbSeek(xFilial("GAV") + GCY->GCY_CODLOC + GCY->GCY_QUAINT + GCY->GCY_LEIINT )
		HS_M30CAL("GAV", GAV->(Recno()), 2)
	EndIf
EndIf
 
UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.) 
HSPDelFiCo("ExecM24",GCY->GCY_REGATE)

RestArea(aArea)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_SPrM24  ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro de solicitacao de prontuario                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de atendimentos                        ³±±
±±³          ³ExpN2: Recno do registro de atendimento                       ³±±
±±³          ³ExpN3: Número da opção escolhida                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_SPrM24(cAliasM24, nRegM24, nOpcM24)
Local aCpoEnchoice  :={}, aCpoEdita := {}, nOpcA := 0
Local cCodLoc := "", cRegGer := ""
Local lMosCrm := .T.
Local aArea   := GetArea()  
Local oEncGsa, oDlg
Private aTela := {}, aGets := {}, aSize := {} 
Private cGsbRegGer := "" // Variavel utilizada no filtro da consulta padrão HS_FilGsb()
Private cGsaRegGer := ""
Private cRegate:=""

 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
  
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 

//HS_PosSX1({{"HSP24A", "01", GCY->GCY_REGGER}})
HS_PosSX1({{"HSP24A", "01", ""}})
HS_PosSX1({{"HSP24A", "02", ""}})

If !Pergunte("HSP24A", .T.)
	Return()	
EndIf

If !Empty(MV_PAR01) .and. MV_PAR01 <> GCY->GCY_REGGER    
 lMosCrm := .F.
 cRegGer := MV_PAR01  
 cCodLoc := cM24par01        
 cRegate := MV_PAR02
Else
 cRegGer := GCY->GCY_REGGER
 cCodLoc := GCY->GCY_CODLOC 
 cRegate := GCY->GCY_REGATE
Endif 
cGsaRegGer :=cRegGer
 
DbSelectArea("GBH")
DbSetOrder(1)
DBSeek(xFilial("GBH")+ cRegGer)
 
cGsbRegGer := GBH->GBH_CODPAC

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("GSA")
While !Eof() .And. (SX3->X3_ARQUIVO == "GSA")
	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .and. SX3->X3_CAMPO <> "GSA_CODSOL" 
		AADD(aCpoEnchoice, SX3->X3_CAMPO)
	Endif
	
	If SX3->X3_CAMPO $ "GSA_CODEND|GSA_CODPRO|GSA_CODMOT|GSA_OBSERV"
		AADD(aCpoEdita, SX3->X3_CAMPO)
	ElseIf SX3->X3_CAMPO == "GSA_CODCRM" .And. !lMosCrm
		AADD(aCpoEdita, SX3->X3_CAMPO)
	EndIf
	
	If SX3->X3_CAMPO == "GSA_REGGER"
		&("M->" + SX3->X3_CAMPO) := GBH->GBH_CODPAC
	ElseIf SX3->X3_CAMPO == "GSA_CODCRM" .And. lMosCrm
		&("M->" + SX3->X3_CAMPO) := GCY->GCY_CODCRM
	ElseIf SX3->X3_CAMPO == "GSA_NOMMED" .And. lMosCrm
		&("M->" + SX3->X3_CAMPO) := Posicione("SRA", 11, xFilial("GCS") + GCY->GCY_CODCRM, "RA_NOME")
	ElseIf SX3->X3_CAMPO == "GSA_NOMPAC"
		&("M->" + SX3->X3_CAMPO) := GBH->GBH_NOME
	ElseIf SX3->X3_CAMPO == "GSA_CODLOC"
		&("M->" + SX3->X3_CAMPO) := cCodLoc
	ElseIf SX3->X3_CAMPO == "GSA_NOMLOC"
		&("M->" + SX3->X3_CAMPO) := Posicione("GCS", 1, xFilial("GCS") + cCodLoc, "GCS_NOMLOC")
	ElseIf SX3->X3_CAMPO == "GSA_CODMOT"
		&("M->" + SX3->X3_CAMPO) := GCS->GCS_CODMOT
	ElseIf SX3->X3_CAMPO == "GSA_NOMMOT"
		&("M->" + SX3->X3_CAMPO) := HS_INIPADR("GSC", 1, GCS->GCS_CODMOT, "GSC_DESMOT",,.F.)  
	ElseIf SX3->X3_CAMPO == "GSA_DTNASC"
		&("M->" + SX3->X3_CAMPO) := GBH->GBH_DTNASC
	ElseIf SX3->X3_CAMPO == "GSA_SEXO  "
		&("M->" + SX3->X3_CAMPO) := GBH->GBH_SEXO
	If GSA->(FieldPos("GSA_REGATE")) > 0
	ElseIf SX3->X3_CAMPO == "GSA_REGATE  "
		&("M->" + SX3->X3_CAMPO) := GCY->GCY_REGATE
     Endif 
 Else
		&("M->" + SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
	EndIf 
	
	DbSelectArea("SX3")
	DbSkip()
End

DbSelectArea("GSA")
If GSA->(FieldPos("GSA_REGATE")) > 0
	M->GSA_REGATE :=GCY->GCY_REGATE
Endif

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0001 )  From aSize[7],000 TO aSize[6],aSize[5] Of oMainWnd pixel //"Solicitacao de protuario"

oEncGsa := MsMGet():New("GSA", 0, nOpcM24,,,, aCpoEnchoice,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, aCpoEdita, 3,,,, oDlg,,.F.)
oEncGsa:oBox:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela), oDlg:End(), nOpca := 1)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpca == 1
	DbSelectArea("GSA")
	Begin Transaction
	M->GSA_CODSOL := HS_VSxeNum("GSA", "M->GSA_CODSOL", 1)
	RecLock("GSA", .T.)
	HS_GRVCPO("GSA") 
	GSA->GSA_NOMSOL := cUserName
	GSA->GSA_LOGARQ := HS_LOGARQ()
	MsUnlock()
	
	While __lSx8
		ConfirmSx8()
	End
	End Transaction
	Hs_MsgInf(STR0027 + GSA->GSA_CODSOL + STR0028, STR0003, STR0001)//"Solicitação ["##"] gerada com sucesso"##Atencao##Solicitacao prontuario
Else
	While __lSx8
		RollBackSX8()
	End
Endif
cGsbRegGer := ""
cGsaRegGer := ""
RestArea(aArea)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_EXAM24  ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Entrega de Exames                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de atendimentos                        ³±±
±±³          ³ExpN2: Recno do registro de atendimento                       ³±±
±±³          ³ExpN3: Número da opção escolhida                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_EXAM24(cAliasM24, nRegM24, nOpcM24)
HS_MsgInf(STR0039, STR0003, STR0040) //"Opção não disponivel"###"Atenção"###"Entrega de exames"

/* Verificar nova forma de tratamento dos laudos para habilitar as linhas abaixo
Local aCposAlt := {}, aCposObr := {}, aCposGcy := {}
Local aArea := GetArea()

Local aHeadGBY := {}
Local aColsGBY := {}
Local nUsadGBY := 0

Local aHeadTMP := {}
Local aColsTMP := {}
Local nUsadTMP := 0

Local nGDOpc := 0

Local nGBY_ENTREG := 0

Private oGetGBY	:= Nil
Private oDlg				:= Nil

DbSelectArea("GCY")

RegToMemory("GCY", .F.)
HS_CposGcy(nOpcM24, @aCposObr, @aCposGcy, @aCposAlt)

DbSelectArea("GBX")
DbSetOrder(1)
DbSeek(xFilial("GBX") + M->GCY_REGATE)

// Carrega aHeadGby sem adcionar registros no aColsGby
HS_BDados("GBY", @aHeadGby, @aColsGby, @nUsadGby, 1, GBX->GBX_SOLICI, Nil,,, "GBY_SOLICI",,, .F.,"GBY_ENTREG", "Iif(GBY->GBY_ENTREG == '0', 'LBNO', 'LBTIK')")

Do While GBX->GBX_REGATE == M->GCY_REGATE .and. !Eof()
aHeadTMP := {}
aColsTMP := {}
nUsadTMP := 0

HS_BDados("GBY", @aHeadTMP, @aColsTMP, @nUsadTMP, 1, GBX->GBX_SOLICI, "GBY->GBY_SOLICI == '" + GBX->GBX_SOLICI + "'",,, "GBY_SOLICI",,,,"GBY_ENTREG", "Iif(GBY->GBY_ENTREG == '0', 'LBNO', 'LBTIK')")

aEval(aColsTMP, {|x| aAdd(aColsGBY, aClone(x))})

DbSkip()
Enddo

If Len(aColsGby) > 0
nGBY_ENTREG := aScan(aHeadGBY, {|x| AllTrim(x[2]) == "GBY_ENTREG"})

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0002) FROM 120,000 TO 516,665 OF oMainWnd PIXEL //"Exames Entregues"
Enchoice("GCY", nRegM24, nOpcM24,,,, aCposGcy, {14,03,83,332}, aCposAlt, 2,,,, oDlg)

oGetGBY := MsNewGetDados():New(90,03,190,332, nGDOpc,,,,,,,,,, oDlg, aHeadGBY, aColsGBY)
oGetGBY:oBrowse:BlDblClick := {|| FS_M24EXDC(nGBY_ENTREG) }
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| FS_M24GENT(nGBY_ENTREG), oDlg:End()}, {|| oDlg:End()})
Else
Help(STR0003, 1, "HM24EXAVAZ",, STR0004 + Chr(13) + Chr(10) + AllTrim(GCY->GCY_NOME), 1) //"Atencao"###"Não foi encontrado nenhum exame para o paciente "
EndIf
RestArea(aArea)
*/
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_M24GENT³ Autor ³ Robson Ramiro A. Olive³ Data ³ 27.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava Exames entregues                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS_M24GENT()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M24                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/* Verificar nova forma de tratamento dos laudos para habilitar as linhas abaixo
Static Function FS_M24GENT(nPos)

Local nIt 								:= 0
Local nGBY_SOLICI	:= aScan(oGetGBY:aHeader, {|x| AllTrim(x[2]) == "GBY_SOLICI"})
Local nGBY_PROSOL := aScan(oGetGBY:aHeader, {|x| AllTrim(x[2]) == "GBY_PROSOL"})

Begin Transaction

DbSelectArea("GBY")

For nIt := 1 To Len(oGetGBY:aCols)

If DbSeek(xFilial("GBY") + oGetGBY:aCols[nIt, nGBY_SOLICI] + oGetGBY:aCols[nIt, nGBY_PROSOL])

RecLock("GBY", .F.)
If oGetGBY:aCols[nIt, nPos] == "LBTIK"
GBY->GBY_ENTREG := "1"
Else
GBY->GBY_ENTREG := "0"
Endif
MsUnlock()

Endif

Next nIt

End Transaction

Return Nil
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_M24EXDC³ Autor ³ Robson Ramiro A. Olive³ Data ³ 27.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marca/Desmarca                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS_M24EXDC                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/* Verificar nova forma de tratamento dos laudos para habilitar as linhas abaixo
Static Function FS_M24EXDC(nPos)

If oGetGBY:aCols[oGetGBY:oBrowse:nAt, nPos] == "LBNO"
oGetGBY:aCols[oGetGBY:oBrowse:nAt, nPos] := "LBTIK"
Else
oGetGBY:aCols[oGetGBY:oBrowse:nAt, nPos] := "LBNO"
Endif

oGetGBY:oBrowse:Refresh()

Return .T.
*/


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_M24LOKR ³ Autor ³ Robson Ramiro A. Olive³ Data ³08.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consiste linha da MsNewGetDados do recém-nascido              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Linha Ok                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_RNAM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M24LOKR

Local lRet    := .T.
Local nCont   := 0
Local nPosDel	:= Len(aHeader) + 1
Local	nPos				:= aScan(aHeader, {|x| AllTrim(x[2]) == "GB2_TPNASC"})

If !aCols[n, nPosDel]
	If nPos <> 0
		aEval(aCols, { |x| Iif(!x[nPosDel] .and. x[nPos] == aCols[ n, nPos], nCont++, nCont) })
		If nCont > 1
			MsgStop(STR0005) //"Informacao ja cadastrada!"
			lRet := .F.
		Endif
	Endif
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RNAM24  ³ Autor ³ Robson Ramiro A. Olive³ Data ³04.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro de recém-nascidos                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Se recém-nascidos cadastrados com sucesso                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de atendimentos                        ³±±
±±³          ³ExpN2: Recno do registro de atendimento                       ³±±
±±³          ³ExpN3: Número da opção escolhida                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPM24AI,HS_RNaM30                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RNAM24(cAlias, nReg, nOpc)

Local aArea 	:= GetArea()
Local oDlg		:= Nil
Local lOk 		:= .F.
Local nIt		:= 0
Local nCpo		:= 0
Local lAchou	:= .F.
Local lGravaGAV := .F.

Local aHeadGB2	:= {}
Local aColsGB2	:= {}
Local nUsadGB2	:= 0
Local nGDOpc	:= (GD_INSERT + GD_UPDATE)

Local nPosDel		:= 0
Local nGB2_TPNASC	:= 0

Local cCCUSRN	:= PadR(GetMv("MV_CCUSRN"), Len(GAV->GAV_CODLOC))	// Setor (CC) Padrão para Internação dos Recém-Nascidos
Local cQUARRN	:= PadR(GetMv("MV_QUARRN"), Len(GAV->GAV_QUARTO))	// Quarto Padrão para Internação dos Recém-Nascidos
Local cCpoNao	:= "GB2_CODCRM/GB2_NOMMED"
Local lRet      := .T.

Private oGetGB2      //Utilizada no X3_When do campo GB2_TPNASC
Private nLenGB2		:= 0 //Utilizada no X3_When do campo GB2_TPNASC
Private nGB2STNASC	:= 0, nGB2APGAR := 0, nGB2APGAR2 := 0, nNomeRn := 0
Private aCols := {}   
Private aTela := {}, aGets := {}

If GCY->GCY_TPALTA == "99"
	HS_MsgInf(STR0079, STR0003, STR0080) //"Não é possível incluir RN para atendimento cancelado."###"Atenção"###"Validação de Atendimento"
	Return(.T.)
EndIf

If Empty(cCCusRN)
	MsgStop(STR0019 + "MV_CCUSRN" + STR0020) //"Setor de RNs nao cadastrado no parametro "###". Por favor, atualize o parametro"
	Return()
Endif
DbSelectArea("GCS")
DbSetOrder(1)
If !DbSeek(xFilial("GCS") + cCCusRN)
	MsgStop(STR0021 + "MV_CCUSRN" + STR0022) //"O setor cadastrado no parametro "###" nao esta cadastrado. Verifique!"
	Return()
Endif
If GCS->GCS_TIPLOC <> "8" //Bercario
	MsgStop(STR0021 + "MV_CCUSRN" + STR0023) //"O setor cadastrado no parametro "###" nao e do tipo BERCARIO. Verifique!"
	Return()
Endif

GBH->(DbSetOrder(1))
If GBH->(DbSeek(xFilial("GBH") + GCY->GCY_REGGER))
	If GBH->GBH_SEXO <> "1"
		MsgStop(STR0006) //"Cadastro so permitido para o sexo feminino!"
		Return
	Endif
Endif

  //Verifica se existe leito disponivel
	If HS_CountTB("GAV","GAV_STATUS = '0' And GAV_CODLOC = '" + cCCUSRN + "'" + ; //Checa se o retorno do numero de registros
						   IIf(Empty(cQuarRN), "", " AND GAV_QUARTO = '" + cQuarRN + "'")) == 0
		MsgStop(STR0008) //"Nao foi possivel encontrar leito vago para o recem nascido!"
		nGDOpc := GD_UPDATE
	Endif

DbSelectArea("GCY")
RegToMemory("GCY", .F.)

DbSelectArea("GB2")

nLenGB2 := HS_BDados("GB2", @aHeadGB2, @aColsGB2, @nUsadGB2, 1, GCY->GCY_REGATE, "GB2->GB2_REGATE == '" + GCY->GCY_REGATE + "'",,,,,cCpoNao)
nGB2STNASC := aScan(aHeadGB2, {| aVet | aVet[2] == "GB2_STNASC"})
nGB2APGAR  := aScan(aHeadGB2, {| aVet | aVet[2] == "GB2_APGAR "})
nGB2APGAR2 := aScan(aHeadGB2, {| aVet | aVet[2] == "GB2_APGAR2"})
nNomeRn    := aScan(aHeadGB2, {| aVet | AllTrim(aVet[2]) == "GB2_NOME"})

nPosDel := Len(aHeadGB2) + 1

nGB2_TPNASC := aScan(aHeadGB2, {|x| AllTrim(x[2]) == "GB2_TPNASC"})

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) FROM 120,000 TO 516,665 OF oMainWnd PIXEL //"Cadastro de Recem Nascidos"

Enchoice("GCY", nReg, nOpc,,,,, {14,03,83,332},,)

oGetGB2 := MsNewGetDados():New(90,03,190,332, nGDOpc + GD_DELETE, "HS_M24LOKR",,,,,,,,, oDlg, aHeadGB2, aColsGB2)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,	{|| (lOk := (oGetGB2:TudoOk() .AND. FS_APGAR(oGetGB2)), aColsGB2 := aClone(oGetGB2:aCols)) , Iif(lOk,oDlg:End(), )},;
{|| oDlg:End()})

If lOk
	
	Begin Transaction
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do GB2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("GB2")
	DbSetOrder(1)
	
	For nIt := 1 To Len(aColsGB2)
		
		If !aColsGB2[nIt, nPosDel]  // Verifica se o item foi deletado
			
			lAchou := DbSeek(xFilial("GB2") + M->GCY_REGATE + aColsGB2[nIt, nGB2_TPNASC])
			RecLock("GB2", !lAchou)
			For nCpo := 1 To Len(aHeadGB2)
				If aHeadGB2[nCpo, 10] <> "V"
					GB2->(FieldPut(FieldPos(Trim(aHeadGB2[nCpo, 2])),aColsGB2[nIt, nCpo]))
				Endif
			Next nCpo
			GB2->GB2_FILIAL	:= xFilial("GB2")
			GB2->GB2_CODCRM := M->GCY_CODCRM
			MsUnLock()
			
			If !lAchou
				DbSelectArea("GAV")
				DbSetOrder(1)
				DbSeek(xFilial("GAV") + cCCUSRN + IIf(!Empty(cQuarRN), cQuarRN, ""))
				Do While !Eof() .and. xFilial("GAV") == GAV->GAV_FILIAL .and. GAV->GAV_CODLOC == cCCUSRN .and. ;
					Iif(!Empty(cQuarRN), GAV->GAV_QUARTO == cQuarRN, .T.)
					
					If Empty(GAV->GAV_REGATE)
						lAchou := .T.
						Exit
					EndIf
					
					DbSkip()
				Enddo
				If !lAchou
					MsgStop(STR0008) //"Nao foi possivel encontrar leito vago para o recem nascido!"
					DisarmTransaction()
					lRet   := .F.
					Exit
				Else
					HS_GrvMovH(GCY->GCY_REGATE, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "0", GB2->GB2_DTNASC, GB2->GB2_HORNAS,,,,,,,GB2->GB2_TPNASC,.F.)
				Endif
			Endif
		Else
			DbSelectArea("GB2")
			DbSetOrder(1)
			If DbSeek(xFilial("GB2") + M->GCY_REGATE + aColsGB2[nIt, nGB2_TPNASC])
				RecLock("GB2", .F.)
				DbDelete()
				MsUnLock()
				
				DbSelectArea("GAV")
				DbSetOrder(2)
				DbSeek(xFilial("GAV") + M->GCY_REGATE + aColsGB2[nIt, nGB2_TPNASC])
				RecLock("GAV", .F.)
				GAV->GAV_REGATE := SPACE(Len(GAV->GAV_REGATE))
				GAV->GAV_REGGER := SPACE(Len(GAV->GAV_REGGER))
				GAV->GAV_NOME   := SPACE(Len(GAV->GAV_NOME  ))
				GAV->GAV_DATATE := CToD("")
				GAV->GAV_HORATE := SPACE(Len(GAV->GAV_HORATE))
				GAV->GAV_CODCRM := SPACE(Len(GAV->GAV_CODCRM))
				GAV->GAV_MEDICO := SPACE(Len(GAV->GAV_MEDICO))
				GAV->GAV_OBSERV := SPACE(Len(GAV->GAV_OBSERV))
				GAV->GAV_RESERV := SPACE(Len(GAV->GAV_RESERV))
				GAV->GAV_STATUS := "0"
				GAV_LOGARQ	:= HS_LOGARQ()
				MsUnLock()
				
			Endif
		Endif
	Next nIt
	
	End Transaction
	
Endif

RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_EXTM24C ³ Autor ³ Robson Ramiro A.Olive ³ Data ³14.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe extrato do paciente na tela                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do paciente                                     ³±±
±±³          ³ExpC2: Indica qual tabela de Despesa será considerada,'P' para³±±
±±³          ³       apresentar GD e 'F' para apresentar GE.           (OPC)³±±
±±³          ³ExpN3: Número da opção selecionada                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_A58EXT, HS_EXTM24, HS_M29EXT, FS_IniPrIn, HS_M50EXT,      ³±±
±±³          ³ HS_ExtMa7, HS_HP12EXT, HS_P39                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_EXTM24C(cCodPac, cModo, nOpc)

Local aArea	:= GetArea()

Local oDlg				:= Nil
Local oGetGCY	:= Nil

Local aHeadGCY := {}
Local aColsGCY	:= {}
Local aButtons  := {} 
Local nUsadGCY	:= 0

Local nGCY_REGATE	:= 0
Local aCpoIni := {"GCY_DATATE", "GCY_HORATE","GCY_REGATE","GCY_IDADE ","GCY_SEXO  ","GCY_NOME  ","GCY_CODCRM", ;
"GCY_NOMMED","GCY_CODCLI","GCY_DESCLI","GCY_CODMOT","GCY_MOTCAN"}
Local cCpoNao	:= "GCY_DTNASC/GCY_SEXO/GCY_REGGER/GCY_NOME"
Local cOrderBy:= " GCY_DATATE, GCY_HORATE "
Local lMudou := .F.
Local nVisAnm       := 0   // Variaveis declaradas para a visualizacao da anamnese
Local nQtdAnm       := 0   // Variaveis declaradas para a visualizacao da anamnese
Local cProntuario   := ""

Local aSize		:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local aObjects	:= {}
#IFDEF TOP
	Local aLegAte := {{"TMPGCY->GCY_ATENDI == '0'", "BR_VERMELHO"},; //Internacao
                   {"TMPGCY->GCY_ATENDI == '1'", "BR_AMARELO" },; //Ambulatorial
                   {"TMPGCY->GCY_ATENDI == '2'", "BR_VERDE"   },; //Pronto Atendimento
                   {"TMPGCY->GCY_ATENDI == '3'", "BR_AZUL"    }}  //Doacao
#ELSE
	Local aLegAte := {{"TMPGCY->GCY_ATENDI == '0'", "BR_VERMELHO"},; //Internacao
                   {"TMPGCY->GCY_ATENDI == '1'", "BR_AMARELO" },; //Ambulatorial
                  	{"TMPGCY->GCY_ATENDI == '2'", "BR_VERDE"   },; //Pronto Atendimento
                   {"TMPGCY->GCY_ATENDI == '3'", "BR_AZUL"    }}  //Doacao                  	
#ENDIF

Local aAreaGCY	:= GCY->(GetArea())
Private aGets := {}, aTela := {}, LEDTCODLOC := .F., cLCTCODLOC := GCY->GCY_CODLOC  // para nao gerar erro na enchoice
Private lVisExt  := .T. 
Private cLocCon  := ""
Private cGcsTipLoc := "01234CDE"  // Utilizado na validação e no filtro da pergunta do codigo do setor na impressao da anamnese
Default cModo := "P"

GCY->(DbSetOrder(2))
If ! GCY->(DbSeek(xFilial("GCY") + cCodPac))
	RestArea(aAreaGCY)
EndIf

DbSelectArea("GBH")
DbSetOrder(1)
If !DbSeek(xFilial("GBH") + cCodPac)
	MsgStop(STR0009) //"Paciente nao encontrado!"
	RestArea(aArea)
	Return Nil
Endif

aSize := MsAdvSize()

aObjects := {}

AAdd( aObjects, { 100, 40, .T., .T. } )
AAdd( aObjects, { 100, 50, .T., .T. } )
AAdd( aObjects, { 100, 10, .T., .T. } )

aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 } 

aPosObj := MsObjSize( aInfo, aObjects, .T. ) 




DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0010) FROM aSize[7],000 TO aSize[6]*0.78/*522*/,aSize[5]*0.67/*665*/ OF oMainWnd PIXEL //"Extrato"

If lMudou := INCLUI
	INCLUI := .F.
EndIf

RegToMemory("GBH", .F.)

Enchoice("GBH", Recno(), nOpc,,,,, {aPosObj[1, 1], aPosObj[1, 2], aPosObj[1, 3]*0.74, aPosObj[1, 4]*0.68}/*{14, 03, 83, 332}*/,,,,,)

HS_BDados("GCY", @aHeadGCY, @aColsGCY, @nUsadGCY, 1,, "GCY->GCY_REGGER == '" + M->GBH_CODPAC + "'",, "GCY_ATENDI",,, cCpoNao,,,,, aLegAte,,.T.,,, aCpoIni,,, cOrderBy)

nGCY_REGATE := aScan(aHeadGCY, {|x| AllTrim(x[2]) == "GCY_REGATE"})

oGetGCY := MsNewGetDados():New(aPosObj[2,1]*0.78,aPosObj[2,2],aPosObj[2,3]*0.78,aPosObj[2,4]*0.67/*90, 03, 190, 332*/, 00,,,,,,,,,,, aHeadGCY, aColsGCY)

oGetGCY:oBrowse:BlDblClick := {|| FS_EXTDM24(aColsGCY[oGetGCY:oBrowse:nAt, nGCY_REGATE], cModo)}

@ aPosObj[3,1]*0.78/*194*/,aPosObj[3,2]*5/*015*/ BitMap NAME "BR_VERMELHO" SIZE 8, 8 NOBORDER Of oDlg PIXEL
@ aPosObj[3,1]*0.78/*194*/, aPosObj[3,2]*8.34/*025*/ Say STR0011 Of oDlg PIXEL //"Internacao"

@ aPosObj[3,1]*0.78/*194*/, aPosObj[3,2]*28.34 /*085*/ BitMap NAME "BR_AMARELO" SIZE 8, 8 NOBORDER Of oDlg PIXEL
@ aPosObj[3,1]*0.78/*194*/, aPosObj[3,2]*31.7/*095*/ Say STR0012 Of oDlg PIXEL //"Ambultaorial"

@ aPosObj[3,1]*0.78/*194*/, aPosObj[3,2]*51.7/*155*/ BitMap NAME "BR_VERDE" SIZE 8, 8 NOBORDER Of oDlg PIXEL
@ aPosObj[3,1]*0.78/*194*/, aPosObj[3,2]*55/*165*/ Say STR0013 Of oDlg PIXEL //"Pronto atendimento"

@ aPosObj[3,1]*0.78/*194*/, aPosObj[3,2]*75/*225*/ BitMap NAME "BR_AZUL" SIZE 8, 8 NOBORDER Of oDlg PIXEL
@ aPosObj[3,1]*0.78/*194*/, aPosObj[3,2]*78.4/*235*/ Say "Doação" Of oDlg PIXEL //"Doacao"

//Adciona o botao Anamnese no extrato do Paciente  
                                                                                  
Aadd(aButtons, {"S4WB011N",       {|| IIf (!(aCodUsr := HS_VldDAnm(.T.))[1],NIL,FS_ANMEXT(IIf(Empty(cProntuario),cCodPac,cProntuario),GCY->GCY_REGATE) )}, STR0094})   //Anamnese

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End()},,@aButtons)

If lMudou
	INCLUI := .T.
EndIf

RestArea(aArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_EXTDM24 ³ Autor ³ Robson Ramiro A. Olive³ Data ³15.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Detalhes do extrato do paciente                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Registro de Atendimento                                ³±±
±±³          ³ExpC2: Indica qual tabela de Despesa será considerada,'P' para³±±
±±³          ³       apresentar GD e 'F' para apresentar GE.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_EXTM24C                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_EXTDM24(cRegAte, cModo)

Local cLstCpo    	:= ""
Local cCamposNao 	:= ""
Local nDados		:= 0

Private oDlg		:= Nil
Private oGCZ        := Nil
Private oFolder	    := Nil

Private oGetG5	:= Nil
Private oGetG6	:= Nil
Private oGetG7	:= Nil
Private oGetGE3	:= Nil
Private oGetGE2	:= Nil

Private aHeadG5	:= {}
Private aColsG5	:= {}
Private nUsadG5	:= 0
Private nLenG5	:= 0

Private aHeadG6 := {}
Private aColsG6 := {}
Private nUsadG6 := 0
Private nLenG6  := 0

Private aHeadG7	:= {}
Private aColsG7	:= {}
Private nUsadG7	:= 0
Private nLenG7	:= 0

Private aHeadGE3	:= {}
Private aColsGE3	:= {}
Private nUsadGE3	:= 0
Private nLenGE3		:= 0

Private aHeadGE2	:= {}
Private aColsGE2	:= {}
Private nUsadGE2	:= 0
Private nLenGE2		:= 0
Private aHeadGCZ	:= {}
Private aColsGCZ	:= {}
Private nUsadGCZ	:= 0
Private nGCZ_NRSEQG := 0
Private nMv_VldGui := 0
Private aLegGe2 := 	{{"GE2_STATUS == '0'", "BR_VERDE"},{"GE2_STATUS == '1'", "BR_AMARELO"},;
                  	{"GE2_STATUS == '2'", "BR_AZUL"},{"GE2_STATUS == '3'", "BR_VERMELHO"},{"GE2_STATUS == '4'", "BR_PRETO"},{"GE2_STATUS == '5'", "BR_LARANJA"}}                  
Private aLegGe3 := 	{{"GE3_STATUS == '0'", "BR_VERDE"},{"GE3_STATUS == '1'", "BR_AMARELO"},;
                  	{"GE3_STATUS == '2'", "BR_AZUL"},{"GE3_STATUS == '3'", "BR_VERMELHO"},{"GE3_STATUS == '4'", "BR_PRETO"},{"GE3_STATUS == '5'", "BR_LARANJA"}}  

If Empty(cRegAte)
	Return(Nil)
Endif

cLstCpo    := "GCZ_NRLOTE"
cCamposNao := "GCZ_CMCAIH/GCZ_DMCAIH/GCZ_IDGUIA/GCZ_AIHANT/GCZ_AIHPOS/GCZ_CDCBOR/GCZ_DSCBOR/GCZ_CDCCNA/GCZ_DESCNA/" +;
              "GCZ_TPVINC/GCZ_RNNVIV/GCZ_RNNOBI/GCZ_RNALTA/GCZ_RNTRAN/GCZ_RNOBIT/GCZ_CPRAU1/GCZ_DPRAU1/GCZ_CPRAU2/" +;
              "GCZ_DPRAU2/GCZ_CPRAU3/GCZ_DPRAU3/GCZ_CPRAU4/GCZ_DPRAU4/GCZ_CPRAU5/GCZ_DPRAU5/GCZ_DIASAC/GCZ_DTADIA/" +;
              "GCZ_CPFAUD/GCZ_MESINI/GCZ_MESANT/GCZ_MESALT/GCZ_IDAUTE/GCZ_CPFGES/GCZ_DATAUT/GCZ_CODAUT"

RegToMemory("GCY", .F., .F.)

nDados := HS_BDados("GCZ", @aHeadGCZ, @aColsGCZ, @nUsadGCZ, 2, cRegAte, "'" + cRegAte + "' == GCZ_REGATE",,, cLstCpo,,cCamposNao )
nGCZ_NRSEQG := aScan(aHeadGCZ, {|x| AllTrim(x[2]) == "GCZ_NRSEQG"})

FS_DdDesp(cModo, aColsGCZ[1, nGCZ_NRSEQG])

If nDados > 0
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0014) From 07,0 to 30,85	of oMainWnd //"Detalhes"
	
	oGCZ   := MsNewGetDados():New(005, 000, 053, 335, 0,,,,,,,,,, oDlg, aHeadGCZ, aColsGCZ)
	oGCZ:oBrowse:Align := CONTROL_ALIGN_TOP
	oGCZ:bChange := {||  FS_DdDesp(cModo, aColsGCZ[oGCZ:nAt, nGCZ_NRSEQG]) }
	
	@ 065,000 FOLDER oFolder Size 337,117	 Of oDlg PROMPTS STR0015 ,STR0016, STR0017, "Autorização Procedimento", "Autorização Mat/Med" Pixel //"Procedimentos"###"Materiais"###"Taxas" "Autorização Procedimento" "Autorização Mat/Med"
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	oGetG7 := MsNewGetDados():New(000, 000, 109, 333, 0,,,,,,,,,, oFolder:aDialogs[1], aHeadG7, aColsG7)
	oGetG7:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	oGetG5 := MsNewGetDados():New(000, 000, 143, 335, 0,,,,,,,,,, oFolder:aDialogs[2], aHeadG5, aColsG5)
	oGetG5:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	oGetG6 := MsNewGetDados():New(000, 000, 143, 335, 0,,,,,,,,,, oFolder:aDialogs[3], aHeadG6, aColsG6)
	oGetG6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	

	oGetGE3 := MsNewGetDados():New(000, 000, 109, 333, 0,,,,,,,,,, oFolder:aDialogs[4], aHeadGE3, aColsGE3)
	oGetGE3:oBrowse:BlDblClick := {|| FS_DbClkGE(oGetGE3)}
	oGetGE3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	oGetGE2 := MsNewGetDados():New(000, 000, 143, 335, 0,,,,,,,,,, oFolder:aDialogs[5], aHeadGE2, aColsGE2)
	oGetGE2:oBrowse:BlDblClick := {|| FS_DbClkGE(oGetGE2)}
	oGetGE2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		
	oFolder:aDialogs[1]:lActive := IIf(nLenG7 == 0, .F., .T.)
	oFolder:aDialogs[2]:lActive := IIf(nLenG5 == 0, .F., .T.)
	oFolder:aDialogs[3]:lActive := IIf(nLenG6 == 0, .F., .T.)
	oFolder:aDialogs[4]:lActive := IIf(nLenGE3 == 0, .F., .T.)
	oFolder:aDialogs[5]:lActive := IIf(nLenGE2 == 0, .F., .T.)
	oFolder:nOption := IIF(nLenG7==0, IIF(nLenG5==0, 3, 2), 1)
	oGetG5:oBrowse:Refresh()
	oGetG6:oBrowse:Refresh()
	oGetG7:oBrowse:Refresh()
	oGetGE3:oBrowse:Refresh()
	oGetGE2:oBrowse:Refresh()
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,	{|| oDlg:End()}, {|| oDlg:End()} )
Else
	MsgAlert(STR0093)	//"Não existe(m) Guia(s) para o atendimento selecionado"
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_DbClkGEºAutor  ³Rogerio Tabosa      º Data ³ 11/05/09    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para apresentar a tela de legenda para itens         º±±
±±º          ³em processo de autorização                                  º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DbClkGE(oGet)

If ValType(oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos]) == "C"
	If "BR_" $ oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos]  
		FS_LEGDGE()
 	EndIf
Else
	Return(Nil)
EndIf 
 
Return(Nil)

Static Function FS_LEGDGE()
Local aLegenda := {{"BR_VERDE"   , "Pendente" }, ;  
                   {"BR_AMARELO", "Aguardando Autorização"}, ;  
                   {"BR_AZUL"   , "Autorizada"},; 
                   {"BR_VERMELHO"  , "Não Autorizada"},;
                   {"BR_PRETO"  , "Cancelado"},;
                   {"BR_LARANJA"  , "Particular"}} 

BrwLegenda("Autorização de itens", "Legenda", aLegenda) 
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_DdDesp  ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que executa a bDados para os grids no detalhamento     ³±±
±±³          ³do extrato do paciente                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Indica qual tabela de Despesa será considerada,'P' para³±±
±±³          ³       apresentar GD e 'F' para apresentar GE.                ³±±
±±³          ³ExpC2: Sequencial da guia.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FS_EXTDM24                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_DdDesp(cModo, cNrSeqG)
Local	cPArq := ""
Local	cAArq := ""

If EMPTY(cModo)
 If GCZ->GCZ_STATUS >= "2" //faturados
  cModo := "F"
 Else 
  cModo := "P"  
 EndIf
EndIf
cPArq := Iif(cModo == "P", "GD5->GD5", "GE5->GE5")
cAArq := Iif(cModo == "P", "GD5"     , "GE5"     )
nLenG5 := HS_BDados(cAArq, @aHeadG5, @aColsG5, @nUsadG5, 2, cNrSeqG, "'" + cNrSeqG + "' == " + cPArq + "_NRSEQG")

cPArq := Iif(cModo == "P", "GD6->GD6", "GE6->GE6")
cAArq := Iif(cModo == "P", "GD6"     , "GE6"     )
nLenG6 := HS_BDados(cAArq, @aHeadG6, @aColsG6, @nUsadG6, 3, cNrSeqG, "'" + cNrSeqG + "' == " + cPArq + "_NRSEQG")

cPArq := Iif(cModo == "P", "GD7->GD7", "GE7->GE7")
cAArq := Iif(cModo == "P", "GD7"     , "GE7"     )
nLenG7 := HS_BDados(cAArq, @aHeadG7, @aColsG7, @nUsadG7, 3, cNrSeqG, "'" + cNrSeqG + "' == " + cPArq + "_NRSEQG")

nLenGE3 := HS_BDados("GE3", @aHeadGE3, @aColsGE3, @nUsadGE3, 1, cNrSeqG, "'" + cNrSeqG + "' == GE3->GE3_NRSEQG",,"GE3_STATUS",,,,,,,,aLegGe3)
nLenGE2 := HS_BDados("GE2", @aHeadGE2, @aColsGE2, @nUsadGE2, 1, cNrSeqG, "'" + cNrSeqG + "' == GE2->GE2_NRSEQG",,"GE2_STATUS",,,,,,,,aLegGe2)
If oFolder # Nil
	oFolder:aDialogs[1]:lActive := IIf(nLenG7 == 0, .F., .T.)
	oFolder:aDialogs[2]:lActive := IIf(nLenG5 == 0, .F., .T.)
	oFolder:aDialogs[3]:lActive := IIf(nLenG6 == 0, .F., .T.)
	oFolder:aDialogs[4]:lActive := IIf(nLenGE3 == 0, .F., .T.)
	oFolder:aDialogs[5]:lActive := IIf(nLenGE2 == 0, .F., .T.)	
	oFolder:nOption := IIF(nLenG7==0, IIF(nLenG5==0, 3, 2), 1)
	oGetG5:oBrowse:Refresh()
	oGetG6:oBrowse:Refresh()
	oGetG7:oBrowse:Refresh()
	oGetGE3:oBrowse:Refresh()
	oGetGE2:oBrowse:Refresh()		
Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_Sexo_Quarto³ Autor ³ Gestão Hospitalar  ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna sexo do paciente ocupante do quarto caso seja         ³±±
±±³          ³necessário validar isso.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC: Sexo do paciente ocupante do quarto                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do setor                                        ³±±
±±³          ³ExpC2: Código do quarto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_VldM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_Sexo_Quarto(cCodLoc, cQuarto)
Local cAliasOld   := Alias()
Local aArea  		   := HS_SavArea({{"GCY", 0, 0}, {"GAV", 0, 0}, {"GBH", 0, 0}})
Local cSexoNaoVal := GETMV("MV_SEXNVAL")
Local cSexoQt     := ""

DbSelectArea("GCS")
DbSetOrder(1) //GCS_FILIAL + GCS_CODLOC
DbSeek(xFilial("GCS") + cCodLoc)
If GCS->GCS_VLDSEX == "0" //0=Nao valida o sexo dos leitos
	Return(cSexoQt)
Endif

DbSelectArea("GAV")
DbSetOrder(1)

If DbSeek(xFilial("GAV") + cCodLoc + cQuarto)
	cSexoQt := GAV->GAV_SEXO
	If GAV->GAV_TIPO $ cSexoNaoVal
		cSexoQt := "" // para nao validar
	ElseIf GAV->GAV_SEXO == "2"
		While !Eof() .And. GAV->GAV_FILIAL == xFilial("GAV") .And. GAV->GAV_CODLOC == cCodLoc .And. GAV->GAV_QUARTO == cQuarto
			If !Empty(GAV->GAV_REGATE)
				DbSelectArea("GCY")
				DbSetOrder(1)
				DbSeek(xFilial("GCY") + GAV->GAV_REGATE)
				
				DbSelectArea("GBH")
				DbSetOrder(1)
				DbSeek(xFilial("GBH") + GCY->GCY_REGGER)
				cSexoQt := GBH->GBH_SEXO
				
				Exit
			EndIf
			
			DbSelectArea("GAV")
			dbSkip()
		End
	EndIf
EndIf

HS_ResArea(aArea)
DbSelectArea(cAliasOld)
Return(cSexoQt)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_IGuiaP  ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que inclui guia do plano particular(MV_PLANPAR) quando ³±±
±±³          ³há despesas excedidas no atendimento ou inclui uma guia do    ³±±
±±³          ³plano passado no parâmetro cCodPla                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se incluiu a guia com sucesso.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Registro de Atendimento                                ³±±
±±³          ³ExpC2: Código do prontuário do paciente                       ³±±
±±³          ³ExpC3: Status da guia a ser inserida                          ³±±
±±³          ³ExpC4: Tipo de atendimento                                    ³±±
±±³          ³       "0" para internação                                    ³±±
±±³          ³       "1" para ambulatorial                                  ³±±
±±³          ³       "2" para pronto atendimento                            ³±±
±±³          ³       "3" para atendimento doacao                            ³±±
±±³          ³ExpD5: Data do atendimento                                    ³±±
±±³          ³ExpC6: Setor de atendimento                                   ³±±
±±³          ³ExpC7: Código do Plano                                   (OPC)³±±
±±³          ³ExpC8: Código do Tipo de Guia a ser inserido             (OPC)³±±
±±³          ³ExpC9: Numero sequencial da guia, que foi incluida pela rotina³±±
±±³          ³       Deve ser passado por referência                   (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FS_M01Guia,Fs_GerGuia,FS_GrvGuia                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_IGuiaP(cRegAte, cRegGer, cStatus, cAtendi, dDatAte, cLocAte, cCodPla, cCODTPG, cRet)
Local cAliasOld := Alias()
Local cCodCon  := ""
Local aRVldVig := {{"", "GC1_TPGINT"}, ;
{"", "GC1_TPGAMB"}, ;
{"", "GC1_TPGPAT"}}

Private aGuiaTiss := {}

Default cCodPla := GetMV("MV_PLANPAR") 
Default cCODTPG := ""
Default cRet    := ""

Private Inclui := .T.

cCOdCon := HS_IniPadr("GCM", 2, cCodPla, "GCM_CODCON",, .F.)
If !HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + cCodPla + "'", "GC1_DATVIG", @aRVldVig, dDataBase)
	Return(.F.)
EndIf

DbSelectArea("GCZ")

RegToMemory("GCZ", .T.)

M->GCZ_NRSEQG := CriaVar("GCZ_NRSEQG")
M->GCZ_NRSEQG := HS_VSxeNum("GCZ", "M->GCZ_NRSEQG", 1)

RecLock("GCZ", .T.)
HS_GrvCpo("GCZ")
GCZ->GCZ_NRSEQG := M->GCZ_NRSEQG
GCZ->GCZ_REGATE := cRegAte
GCZ->GCZ_REGGER := cRegGer
GCZ->GCZ_NOME   := HS_INIPADR("GBH", 1, cRegGer, "GBH_NOME",,.F.)  
GCZ->GCZ_CODTPG := IIF(Empty(cCODTPG),IIf(cAtendi == "0", aRVldVig[1][1], IIf(cAtendi == "1", aRVldVig[2][1], aRVldVig[3][1])),cCODTPG)
GCZ->GCZ_CODCON := cCodCon
GCZ->GCZ_CODPLA := cCodPla
GCZ->GCZ_STATUS := cStatus
GCZ->GCZ_DATSTA := dDataBase
GCZ->GCZ_DATATE := dDatAte
GCZ->GCZ_ATENDI := cAtendi
GCZ->GCZ_LOCATE := cLocAte

GCZ->GCZ_NRGUIA := HS_IniTISS(3,1,cCodPla,GCZ->GCZ_CODTPG,,nil,nil)

If aScan(aGuiaTiss,{|aVet| aVet[1] ==  1}) > 0  .And. HS_ExisDic({{"C","GCZ_ALTGUI"}})
 GCZ->GCZ_ALTGUI := "0"
EndIf

GCZ->GCZ_CANCEL := "0" 
If Hs_ExisDic({{"C", "GCZ_FILFAT"}}) 
 GCZ->GCZ_FILFAT := HS_RetFilF(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, GCZ->GCZ_LOCATE, GCZ->GCZ_CODTPG)
 GCZ->GCZ_FILATE := cFilAnt
EndIf 
GCZ->GCZ_LOGARQ := HS_LogArq()
MsUnlock()
cRet := GCZ->GCZ_NRSEQG
DbSelectArea(cAliasOld)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VldAuto ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se despesa necessita de autorização                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se despesa pode ser lançada                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1: Data de referêmcia                                (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_VldM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldAuto(dDataRef)
Local lRet := .F., cCodCon := Posicione("GCM", 2, xFilial("GCM") + cGczCodPla, "GCM_CODCON")
Local cCodGpp  := ""
Local aRValPR := {}
Local aRVldVig := {{"", "GC1_VALMAT"}, ;
{"", "GC1_VALMED"}, ;
{"", "GC1_VALPRO"}}

Local cMV_AteSus := GetMv("MV_ATESUS",, "N")
Local cCodAIH    := GetMv("MV_PSUSAIH")
Default dDataRef := dDataBase

If ReadVar() == "M->GE2_CODDES"
	If !(lRet := HS_SeekRet("SB1", "M->GE2_CODDES", 1, .F., "GE2_DDESPE", "B1_DESC",,, .T.))
		HS_MsgInf(STR0031, STR0003, STR0032) //"Material/medicamento não cadastrado"###"Atenção"###"Autorização de Materiais/medicamentos"
		
	ElseIf HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + cGczCodPla + "'", "GC1_DATVIG", @aRVldVig, dDataBase)
		If !(lRet := FS_VldVal("MM", M->GE2_CODDES, HS_RValMM(cGczCodPla, M->GE2_CODDES,,.F., dDataBase)[2], aRVldVig))
			If !(lRet := Hs_DespAut(SubStr(ReadVar(),4,3), cGczCodPla, &(ReadVar()), dDataRef, "3"))
				HS_MsgInf(STR0029, STR0003, STR0032) //"O material/medicamento informado não precisa de autorização"###"Atenção" //"Autorização de Materiais/medicamentos"
			EndIf
		EndIf
	EndIf
	
ElseIf ReadVar() == "M->GE3_CODDES"
	If !(lRet := HS_SeekRet("GA7", "M->GE3_CODDES", 1, .F., "GE3_DDESPE", "GA7_DESC",,, .T.))
		HS_MsgInf(STR0033, STR0003, STR0034) //"Procedimento não cadastrado"###"Atenção"###"Autorização de Procedimentos"
		
	ElseIf HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + cGczCodPla + "'", "GC1_DATVIG", @aRVldVig, dDataBase)
		aRValPR := HS_RValPr(M->GE3_CODDES, cGczCodPla, cLctCodLoc, Time(),,,, {cGcyAtendi, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO}, .F., dDataBase)
		If !(lRet := FS_VldVal("PR", M->GE3_CODDES, aRValPR[2][4], aRVldVig))
			If cMV_AteSus =="S" .And. cCodAIH == cGczCodPla
				lRet := HS_VldISPr(M->GE3_CODDES, M->GCY_DTNASC, M->GCY_SEXO)
			Else
				If !(lRet := Hs_DespAut(SubStr(ReadVar(),4,3), cGczCodPla, &(ReadVar()), dDataRef, "4"))
					HS_MsgInf(STR0030, STR0003, STR0034) //"O procedimento informado não precisa de autorização"###"Atenção" //"Autorização de Procedimentos"
				EndIf
			EndIf
		EndIf
	Else	//Valida o Procedimento de acordo com a Idade/Sexo)
		lRet := HS_VldISPr(M->GE3_CODDES, M->GCY_DTNASC, M->GCY_SEXO)
	EndIf
	
	If lRet
		oGDGe3:aCols[oGDGe3:nAt, nGe3CodPrt] := aRValPR[2][15]
	EndIf
ElseIf ReadVar() == "M->GE8_CODCRM"
	IF !(lRet := !Empty(M->GE8_CODCRM))
		HS_MsgInf(STR0035, STR0003, STR0036) //"O CRM do profissional é obrigatório"###"Atenção"###"Prorrogação de guias"
	ElseIf !(lRet := HS_SeekRet("SRA", "M->GE8_CODCRM", 11, .F., "GE8_NOMMED", "RA_NOME",,, .T.))
		HS_MsgInf(STR0037, STR0003, STR0036) //"Profissional nao encontrado"###"Atenção"###"Prorrogação de guias"
	Else
		If !(lRet := !(Posicione("GBJ", 1, xFilial("GBJ") + M->GE8_CODCRM, "GBJ_STATUS") # "1"))
			HS_MsgInf(STR0038, STR0003, STR0036) //"O profissional esta inativo"###"Atenção"###"Prorrogação de guias"###"Prorrogação de guias"
		EndIf
	EndIf
ElseIf ReadVar() $ "M->GD7_CODDES/M->GE7_CODDES"
	lRet    := .T.
	If Hs_DespAut(SubStr(ReadVar(),4,3), cGczCodPla, &(ReadVar()), dDataRef, "4")
		HS_MsgInf(STR0081,STR0003,STR0034)
	EndIf
ElseIf ReadVar() $ "M->GD5_CODBAR/M->GE5_CODBAR"
	lRet := .T.
	If Hs_DespAut(SubStr(ReadVar(),4,3), cGczCodPla, &(ReadVar()), dDataRef, "3")
		HS_MsgInf(STR0082,STR0003,STR0032)
	EndIf
EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_GarM24  ³ Autor ³ José Orfeu            ³ Data ³14.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Garantia                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Atendimento                                   ³±±
±±³          ³ExpN2: Recno do Atendimento                                   ³±±
±±³          ³ExpN3: Opção do aRotina do Atendimento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPM24AI,HSPM24AA,HSPM24PA                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_GarM24(cAliasM24, nRegM24, nOpcM24)
Local aArea	:= GetArea()

Local oDlgGar, oEnGcy, oGDGdq, aHGdq := {}, aCGdq := {}, nUGdq := 0, nOpcGar := 0
Local nGdqNumGar := 0, nGdqStatus := 0, nGdqMarGar := 0, nGdqNumTit := 0, nGdqValGar := 0, nGdqDatGar := 0
Local aCposAlt := {}, aCposObr := {}, aCposGcy := {}

Local aLegGar := {{"TMPGDQ->GDQ_STATUS == '0'", "BR_VERDE"   }, ; //Aberta
{"TMPGDQ->GDQ_STATUS == '1'", "BR_AMARELO" }, ; //Devolvida
{"TMPGDQ->GDQ_STATUS == '2'", "BR_VERMELHO"}, ; //Efetivada
{"TMPGDQ->GDQ_STATUS == '3'", "BR_CINZA"   }}   //Estornada

Local aButtons	:= {{"AFASTAME", {|| FS_GarMnt(0, 2, oGDGdq, nGdqStatus, nGdqMarGar, aLegGar)}, STR0041, STR0042}, ; //"Devolve as garantias marcadas"###"Devolve"
{"AUTOM"   , {|| FS_GarMnt(0, 3, oGDGdq, nGdqStatus, nGdqMarGar, aLegGar)}, STR0043, STR0044}, ; //"Efetiva as garantias marcadas"###"Efetiva"
{STR0045 , {|| FS_GarMnt(2, 4, oGDGdq, nGdqStatus, nGdqMarGar, aLegGar)}, STR0046, STR0047}, ; //"EXCLUIR"###"Estorna as garantias marcadas"###"Estorna"
{"DBG07"   , {|| FS_GarLeg()                                             }, STR0048               , STR0049}} //"Mostra legenda"###"Legenda"

If !LockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCY->GCY_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCY->GCY_REGATE)
EndIf

RegToMemory("GCY", .F.)                                         
HS_CposGcy(nOpcM24, @aCposObr, @aCposGcy, @aCposAlt, (FunName() == "HSPAHP12" .And. M->GCY_TPALTA <> '99' .And. !Empty(M->GCY_DATALT)))

HS_BDados("GDQ", @aHGdq, @aCGdq, @nUGdq, 2, GCY->GCY_REGATE, "'" + GCY->GCY_REGATE + "' == GDQ->GDQ_REGATE",, "GDQ_STATUS",,,,, "GDQ_MARGAR", "'LBNO'",, aLegGar)

nGdqNumGar := aScan(aHGdq, {| aVet | aVet[2] == "GDQ_NUMGAR"})
nGdqStatus := aScan(aHGdq, {| aVet | aVet[2] == "GDQ_STATUS"})
nGdqMarGar := aScan(aHGdq, {| aVet | aVet[2] == "GDQ_MARGAR"})
nGdqNumTit := aScan(aHGdq, {| aVet | aVet[2] == "GDQ_NUMTIT"})
nGdqValGar := aScan(aHGdq, {| aVet | aVet[2] == "GDQ_VALGAR"})
nGdqDatGar := aScan(aHGdq, {| aVet | aVet[2] == "GDQ_DATGAR"})

DEFINE MSDIALOG oDlgGar TITLE OemToAnsi("Garantias") FROM 120,000 TO 522,665 OF oMainWnd PIXEL

oEnGcy := MsMGet():New("GCY", nRegM24, nOpcM24,,,, aCposGcy, {14, 03, 120, 332},, 2,,,, oDlgGar)
oEnGcy:oBox:Align := CONTROL_ALIGN_TOP

oGDGdq := MsNewGetDados():New(90, 03, 190, 332, GD_INSERT + GD_UPDATE + GD_DELETE,,,,,,,,,,, aHGdq, aCGdq)
oGDGdq:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
oGDGdq:OBrowse:bAdd       := {|| FS_GarAddL(oGDGdq, nGdqMarGar, nGdqStatus)}
oGDGdq:oBrowse:bDelete    := {|| IIf(FS_GarDelL(oGDGdq, aLegGar, nGdqStatus), oGDGdq:DelLine(), .F.)}
oGDGdq:oBrowse:BlDblClick := {|| FS_GarDbCk(oGDGdq, nGdqStatus, nGdqNumTit, nUGdq, aLegGar)}

ACTIVATE MSDIALOG oDlgGar ON INIT EnchoiceBar(oDlgGar,	{|| IIf(oGDGdq:TudoOk(), EVal({|| nOpcGar := 1, oDlgGar:End()}), nOpcGar := 0)}, ;
{|| nOpcGar := 0, oDlgGar:End()},, aButtons)

If nOpcGar == 1
	Begin Transaction
	FS_GarGrv(oGDGdq, nGdqNumGar, nGdqStatus, nGdqNumTit, nGdqValGar, nGdqDatGar, nUGdq, aLegGar)
	End Transaction
EndIf

UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)  
HSPDelFiCo("ExecM24",GCY->GCY_REGATE)

RestArea(aArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GarAddL ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona linha na MsNewGetDados oGDGdq                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL: Tudo Ok                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto MsNewGetDados                                   ³±±
±±³          ³ExpN2: Posição do campo de marca na MsNewGetDados             ³±±
±±³          ³ExpN3: Posição do campo de status na MsNewGetDados            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_GarM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GarAddL(oGDGdq, nGdqMarGar, nGdqStatus)
oGDGdq:AddLine()
oGDGdq:aCols[oGDGdq:nAt, nGdqMarGar] := "LBNO"
oGDGdq:aCols[oGDGdq:nAt, nGdqStatus] := "BR_VERDE"
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GarDelL ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validação na deleção da linha na MsNewGetDados oGDGdq         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL: Pode deletar                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto MsNewGetDados                                   ³±±
±±³          ³ExpA2: Array com a legenda do status da garantia              ³±±
±±³          ³ExpN3: Posição do campo de status na MsNewGetDados            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_GarM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GarDelL(oGDGdq, aLegGar, nGdqStatus)
Local lRet := .T.

If !(lRet := !(aScan(aLegGar, {| aVet | aVet[2] == oGDGdq:aCols[oGDGdq:nAt, nGdqStatus]}) - 1) <> 0) // Aberta
	HS_MsgInf(STR0050, STR0003,STR0051) //"Somente as garantias em aberto podem ser excluidas"###"Atenção"###"Garantia"
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GarGrv  ³ Autor ³ Jose Orfeu            ³ Data ³21.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava garantia do paciente                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto MsNewGetDados                                   ³±±
±±³          ³ExpN2: Posição do campo numero da garantia na MsNewGetDados   ³±±
±±³          ³ExpN3: Posição do campo de status na MsNewGetDados            ³±±
±±³          ³ExpN4: Posição do campo numero do titulo na MsNewGetDados     ³±±
±±³          ³ExpN5: Posição do campo valor da garantia na MsNewGetDados    ³±±
±±³          ³ExpN6: Posição do campo data da garantia na MsNewGetDados     ³±±
±±³          ³ExpN7: Posição do último campo do aHeader da MsNewGetDados    ³±±
±±³          ³ExpA8: Array com a legenda do status da garantia              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_GarM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GarGrv(oGDGdq, nGdqNumGar, nGdqStatus, nGdqNumTit, nGdqValGar, nGdqDatGar, nUGdq, aLegGar)
Local nForGdq := 0, lFound := .F., cPrfTit := "", cNumTit := "", cStatus := "", lAtuGdq := .T., nOpcAuto := 0
Local cMVPrefCrh := GetMv("MV_PREFCRH")

For nForGdq := 1 To Len(oGDGdq:aCols)
	DbSelectArea("GDQ")
	DbSetOrder(1)
	lFound := IIf(!Empty(oGDGDQ:aCols[nForGdq, nGdqNumGar]), DbSeek(xFilial("GDQ") + oGDGDQ:aCols[nForGdq, nGdqNumGar]), .F.)
	If !oGDGdq:aCols[nForGdq, nUGdq + 1]
		If !lFound
			M->GDQ_NUMGAR := CriaVar("GDQ_NUMGAR")
			M->GDQ_NUMGAR := HS_VSxeNum("GDQ", "M->GDQ_NUMGAR", 1)
		Else
			M->GDQ_NUMGAR := oGDGdq:aCols[nForGdq, nGdqNumGar]
		EndIf
		
		cStatus := IIf(!lFound, "0", Str(aScan(aLegGar, {| aVet | aVet[2] == oGDGdq:aCols[nForGdq, nGdqStatus]}) - 1, 1))
		
		If (cStatus == "2" .And.  Empty(oGDGdq:aCols[nForGdq, nGdqNumTit])) .Or. ; // Efetivada
			(cStatus == "3" .And. !Empty(oGDGdq:aCols[nForGdq, nGdqNumTit]))        // Estornada
			
			DbSelectArea("GBH")
			DbSetOrder(1)
			DbSeek(xFilial("GBH") + M->GCY_REGGER)
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1") + GBH->GBH_CODCLI + GBH->GBH_LOJA)
			
			If cStatus == "2"
				nOpcAuto := 3
				cPrfTit  := cMVPrefCrh
				cNumTit  := HS_E1Num(cPrfTit)
			Else
				nOpcAuto := 5
				cPrfTit  := GDQ->GDQ_PRETIT
				cNumTit  := GDQ->GDQ_NUMTIT
			EndIf
			lAtuGdq := HS_MkTitCr(cPrfTit, cNumTit, Space(HS_CfgSx3("E1_PARCELA")[SX3->(FieldPos("X3_TAMANHO"))]), "RA ", SA1->A1_NATUREZ, GBH->GBH_CODCLI, GBH->GBH_LOJA, oGDGdq:aCols[nForGdq, nGdqValGar], dDataBase, "GARANTIA " + M->GDQ_NUMGAR, "HSPFUM24", nOpcAuto)
		EndIf
		
		If lAtuGdq
			RecLock("GDQ", !lFound)
			HS_GRVCPO("GDQ", oGDGdq:aCols, oGDGdq:aHeader, nForGdq)
			GDQ->GDQ_FILIAL := xFilial("GDQ")
			GDQ->GDQ_NUMGAR := M->GDQ_NUMGAR
			GDQ->GDQ_REGATE := M->GCY_REGATE
			GDQ->GDQ_STATUS := cStatus
			If (cStatus == "2" .And.  Empty(oGDGdq:aCols[nForGdq, nGdqNumTit])) // Efetivada
				GDQ->GDQ_PRETIT := cPrfTit
				GDQ->GDQ_NUMTIT := cNumTit
			ElseIf (cStatus == "3" .And. !Empty(oGDGdq:aCols[nForGdq, nGdqNumTit]))
				GDQ->GDQ_PRETIT := Space(Len(GDQ->GDQ_PRETIT))
				GDQ->GDQ_NUMTIT := Space(Len(GDQ->GDQ_NUMTIT))
			EndIf
			GDQ->GDQ_LOGARQ := HS_LogArq()
			MsUnlock()
		Endif
	Else
		If lFound
			RecLock("GDQ", .F., .F.)
			DbDelete()
			MsUnLock()
			WriteSx2("GDQ")
		Endif
	Endif
Next
Return(Nil)

                                                                             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GarMnt  ³ Autor ³ Jose Orfeu            ³ Data ³21.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ão ³Marca para devolucao, efetivacao e estorno da garantia do     ³±±
±±³          ³paciente.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Status atual                                           ³±±
±±³          ³ExpN2: Novo Status                                            ³±±
±±³          ³ExpO3: Objeto MsNewGetDados                                   ³±±
±±³          ³ExpN4: Posição do campo de status na MsNewGetDados            ³±±
±±³          ³ExpN5: Posição do campo de marca na MsNewGetDados             ³±±
±±³          ³ExpA6: Array com a legenda do status da garantia              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_GarM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GarMnt(nSitAtu, nSitNov, oGDGdq, nGdqStatus, nGdqMarGar, aLegGar)
Local nForGdq := 0

For nForGdq := 1 To Len(oGDGdq:aCols)
	
	If oGDGdq:aCols[nForGdq, nGdqMarGar] == "LBTIK"
		If (aScan(aLegGar, {| aVet | aVet[2] == oGDGdq:aCols[nForGdq, nGdqStatus]}) - 1) == nSitAtu
			oGDGdq:aCols[nForGdq, nGdqStatus] := aLegGar[nSitNov, 2]
			oGDGdq:aCols[nForGdq, nGdqMarGar] := "LBNO"
		EndIf
	EndIf
	
Next
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GarDbCk ³ Autor ³ Jose Orfeu            ³ Data ³21.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Marca/Desmarca garantia do paciente                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto MsNewGetDados                                   ³±±
±±³          ³ExpN2: Posição do campo de status na MsNewGetDados            ³±±
±±³          ³ExpN3: Posição do campo numero do titulo na MsNewGetDados     ³±±
±±³          ³ExpN4: Posição do último campo do aHeader da MsNewGetDados    ³±±
±±³          ³ExpA5: Array com a legenda do status da garantia              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_GarM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GarDbCk(oGDGdq, nGdqStatus, nGdqNumTit, nUGdq, aLegGar)
Local nPosLeg := 0

If oGDGdq:aHeader[oGDGdq:oBrowse:nColPos, 2] == "GDQ_MARGAR" .And. !oGDGdq:aCols[oGDGdq:nAt, nUGdq + 1]
	nPosLeg := aScan(aLegGar, {| aVet | aVet[2] == oGDGdq:aCols[oGDGdq:nAt, nGdqStatus]}) - 1
	If     nPosLeg == 1 // Devolvida
		HS_MsgInf(STR0052, STR0003, STR0053) //"Garantia devolvida não pode ser marcada"###"Atenção"###"Marca/Desmarca garantia do paciente"
	ElseIf nPosLeg == 2 .And. Empty(oGDGdq:aCols[oGDGdq:nAt, nGdqNumTit]) // Efetivada
		HS_MsgInf(STR0054, STR0003, STR0053) //"Garantia ainda nao foi efetivada e não pode ser marcada"###"Atenção"###"Marca/Desmarca garantia do paciente"
	ElseIf nPosLeg == 3 // Estornada
		HS_MsgInf(STR0055, STR0003, STR0053) //"Garantia estornada não pode ser marcada"###"Atenção"###"Marca/Desmarca garantia do paciente"
	Else
		oGDGdq:aCols[oGDGdq:nAt, oGDGdq:oBrowse:nColPos] := IIf(oGDGdq:aCols[oGDGdq:nAt, oGDGdq:oBrowse:nColPos] == "LBNO", "LBTIK", "LBNO")
	EndIf
Else
	oGDGdq:EDITCELL(oGDGdq:OBROWSE, oGDGdq:oBrowse:nAt, oGDGdq:oBrowse:nColPos)
EndIf

oGDGdq:oBrowse:Refresh()
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VldGdq  ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ão ³Valida existência do tipo de garantia na tabela de tipo de    ³±±
±±³          ³garantia                                                      ³±±                       
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se garantia existe na tabela de tipo de garantia(GDL)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Dicionário de Dados(SX3)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Function HS_VldGdq()
Local lRet := .T.

If ReadVar() == "M->GDQ_CODTGA"
	If !(lRet := HS_SeekRet("GDL","M->GDQ_CODTGA", 1, .F., {"GDQ_DESTGA", "GDQ_VALGAR"}, {"GDL_DESC", "GDL_VALOR"},,, .T.))
		HS_MsgInf(STR0056, STR0003, STR0051) //"Tipo de garantia não encontrado"###"Atenção"###"Garantia"
	EndIf
EndIf

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_GarLeg ³ Autor ³Gestão Hospitalar      ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra legenda da rotina de Garantia	                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_GarM24                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FS_GarLeg()
Local aLegGar := {{"BR_VERDE"   , STR0057   }, ; //"Aberta"
{"BR_AMARELO" , STR0058}, ; //"Devolvida"
{"BR_VERMELHO", STR0059}, ; //"Efetivada"
{"BR_CINZA"   , STR0060}} //"Estornada"

BrwLegenda(STR0051, STR0049, aLegGar) //"Garantia"###"Legenda"
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VM24    ³ Autor ³ Marcelo Jose          ³ Data ³25.07.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida data da solicitação das tabelas GE2 e GE3, e data      ³±±
±±³          ³de prorrogação da guia na tabela GE8                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se solicitação pode ser lançada com data digitada      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opção que indica a tabela que deve ser validada        ³±±
±±³          ³       1 = GE2                                                ³±±
±±³          ³       2 = GE3                                                ³±±
±±³          ³       3 = GE8                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Dicionário de Dados(SX3)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION HS_VM24(nOpt)
Local lRet := .T. , dDataSol /*, nQtdiaMais := 0*/

If nOpt == 1
	
	If M->GE2_DATSOL < GCY->GCY_DATATE
		MSGSTOP(STR0061,STR0003) //"A data de solicitacao nao pode ser Menor que a data do Atendimento..."###"Atencao"
		lRet := .F.
	EndIf
	If !Empty(GCY->GCY_DATALT)
		If M->GE2_DATSOL > GCY->GCY_DATALT
			MSGSTOP(STR0063,STR0003) //"A data de solicitacao nao pode ser Maior que a data da Alta..."###"Atencao"
			lRet := .F.
		EndIf
	EndIf
	
	DbSelectArea("GAI")
	DbSetOrder(2)
	If DbSeek(xFilial("GAI") + GCY->GCY_REGATE)
		While !Eof() .And. GAI->GAI_FILIAL == xFilial("GAI") .And. GAI->GAI_REGATE == GCY->GCY_REGATE
			dDataSol := GAI->GAI_DATSOL
			dbSkip()
		Enddo
		If M->GE2_DATSOL < dDataSol
			MSGSTOP(STR0064,STR0003) //"A data de solicitacao nao pode ser Menor que a data da Ultima Solicitacao..."###"Atencao"
			lRet := .F.
		EndIf
	EndIf
	
ElseIf nOpt == 2
	
	If M->GE3_DATSOL < GCY->GCY_DATATE
		MSGSTOP(STR0061,STR0003) //"A data de solicitacao nao pode ser menor que a data do atendimento..."###"Atencao"
		lRet := .F.
	EndIf
	If !Empty(GCY->GCY_DATALT)
		If M->GE3_DATSOL > GCY->GCY_DATALT
			MSGSTOP(STR0063,STR0003) //"A data de solicitacao nao pode ser Maior que a data da Alta..."###"Atencao"
			lRet := .F.
		EndIf
	EndIf
	
ElseIf nOpt == 3
	
	If Len(aCGE8) > 1
		/*Para as próximas guias a data do vencimento será a data do vencimento da ultima prorrogação + a quantidade de dias liberados.*/
		If oGDGE8:nAt > Len(aCGE8)
			oGDGe8:aCols[oGDGe8:nAt, nGe8DatVen] := aCGE8[Len(aCGE8),nGe8DatVen] + M->GE8_QTDLIB
			oGDGe8:oBrowse:Refresh()
		ElseIf oGDGE8:nAt == Len(aCGE8)
			oGDGe8:aCols[oGDGe8:nAt, nGe8DatVen] := aCGE8[Len(aCGE8)-1,nGe8DatVen] + M->GE8_QTDLIB
			oGDGe8:oBrowse:Refresh()
		EndIf
		
		If oGDGe8:aCols[oGDGe8:nAt, nGe8QtDias] > M->GE8_QTDLIB
			/* Na digitação da quantidade liberada, caso a quantidade de dias liberados for menor que a quantidade de dias solicitados o sistema devera gerar outra solicitação de prorrogação com a diferença entre as quantidades.*/
			nQtdiaMais := oGDGe8:aCols[oGDGe8:nAt, nGe8QtDias] - M->GE8_QTDLIB
			aAdd(aCGE8,oGDGe8:aCols[1] )
			oGDGe8:SetArray(aCGE8)
			oGDGe8:oBrowse:Refresh()
			aCGE8[Len(aCGE8),nGe8CodCrm]   := aCGE8[Len(aCGE8),nGe8CodCrm]
			aCGE8[Len(aCGE8),nGe8CodCrm+1] := Posicione("SRA",11,xFilial("SRA")+aCGE8[Len(aCGE8)-1,nGe8CodCrm],"RA_NOME")
			aCGE8[Len(aCGE8),nGe8DatSol]   := DDATABASE
			aCGE8[Len(aCGE8),nGe8QtDias]   := nQtdiaMais
			aCGE8[Len(aCGE8),nGe8DatVen]   := aCGE8[Len(aCGE8)-1,nGe8DatVen] + nQtdiaMais
			aCGE8[Len(aCGE8),nGe8DatLib]   := DDATABASE
			aCGE8[Len(aCGE8),nGe8QtdLib]   := nQtdiaMais
			oGDGe8:SetArray(aCGE8)
			oGDGe8:oBrowse:Refresh()
		EndIf
		
		lRet := .T.
	EndIf
	
EndIf
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_GSLaudo ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que inclui solicitação do Laudo(GBY)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Registro de Atendimento                                ³±±
±±³          ³ExpC2: Nome do Paciente                                       ³±±
±±³          ³ExpC3: Código procedimento                                    ³±±
±±³          ³ExpC4: Crm do Profissional executante                         ³±±
±±³          ³ExpC5: Crm do Profissional solicitante                        ³±±
±±³          ³ExpC6: Código do setor solicitante                            ³±±
±±³          ³ExpC7: Sequencial da despesa relacionada a laudo              ³±±
±±³          ³ExpC8: Data da solicitação                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_GrvGD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_GSLaudo(cRegAte, cNomPac, cProSol, cCodCrm, cCrmLau, cLocSol, cSeqDes, dDatSol)
 Local aArea := getArea()
 Local lAchou := .F.
 Local cAliasOld := ""
 Local cTipLoc	:= ""

If Hs_ExisDic({{"T", "GP9"}}) // Caso seja executante do Laboratorio abre pedido de exames (Setor Ambulatorio)
	DbSelectArea("GCS")
	DbSetOrder(1)
	If DbSeek(xFilial("GCS") + cLocSol)
	cTipLoc := GCS->GCS_TIPLOC
		If cTipLoc == "1" .AND. FS_VGRPLAB(Posicione("GA7",1,xFilial('GA7')+cProSol,'GA7_CODGPP')) 	
			//GCS->(DbCloseArea())
			 RestArea(aArea)
			Return(Nil)                                                                     
		EndIf
	EndIf
EndIf
 
 DbSelectArea("GBY")
 DbSetOrder(4)
 lAchou := DbSeek(xFilial("GBY") + cSeqDes)

 If !lAchou
  RegToMemory("GBY", .T.)
  M->GBY_SOLICI := HS_VSxeNum("GBY", "M->GBY_SOLICI", 1)
  ConfirmSx8()
 EndIf 

 RecLock("GBY", !lAchou)
  HS_GrvCpo("GBY")
  GBY->GBY_REGATE := cRegAte
  GBY->GBY_REGGER := Hs_IniPadr("GCY", 1, cRegAte, "GCY_REGGER",,.F.)
  GBY->GBY_NOMPAC := cNomPac
  GBY->GBY_PROSOL := cProSol
  GBY->GBY_CODCRM := cCodCrm
  GBY->GBY_CRMLAU := cCrmLau
  GBY->GBY_CODLOC := HS_IsLaudo(cLocSol, cProSol, .T.)[3] // Setor de Laudos
  GBY->GBY_LOCSOL := cLocSol
  GBY->GBY_PROLAU := cProSol
  GBY->GBY_DATSOL := dDatSol
   
  cAliasOld := Alias()
  DbSelectArea("SX3")
  DbSetOrder(2)
  If DbSeek("GBY_DESPRO") .And. SX3->X3_CONTEXT == "R" // Contexto Real
   GBY->GBY_DESPRO := HS_IniPadr("GA7", 1, GBY->GBY_PROSOL, "GA7_DESC",, .F.)
  EndIf
  DbSelectArea(cAliasOld)
  
  If !lAchou
   GBY->GBY_STATUS := "0"
  EndIf
  
  GBY->GBY_SEQDES := cSeqDes
 MsUnLock()

RestArea(aArea) 
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_IsLaudo ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se procedimento em determinado setor solicita laudo  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo:                                        ³±±
±±³          ³       [1] Solicita Laudo                                     ³±±
±±³          ³       [2] Permite alteração do campo "Solicita Laudo" da     ³±±
±±³          ³           Despesa                                            ³±±
±±³          ³       [3] Setor Executante do Laudo                          ³±±
±±³          ³       [4] Procedimento permitido no setor.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do Setor Solicitante                            ³±±
±±³          ³ExpC2: Código do Procedimento Solicitado                      ³±±
±±³          ³ExpL3: Se selecionas setores executantes da                   ³±±
±±³          ³       deve ser passado por referência.                       ³±±
±±³          ³       GNQ(GRUPO PROCEDIMENTO X SETOR)                   (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_GSLaudo,HS_SLaudo,HS_VldM24,HS_M24Agd,HS_ProMed,Fs_CarExm ³±±
±±³          ³ Fs_GDspPr, Fs_GrvCtrl                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_IsLaudo(cCodLoc, cProSol, lSelSetor)
 Local lSolLau := .F., lPerAlt := .F., cAliasOld := Alias(), cLocSol := Space(Len(GCS->GCS_CODLOC))
 Local aArea := HS_SavArea({{"GA7", 0, 0}, {"GCS", 0, 0}, {"GAQ", 0, 0}})
 Local	lProcPer  := .T.
 Local	lProcLaud := .T.
 
 Default lSelSetor := .F.
 
 DbSelectArea("GCS")
 DbSetOrder(1)
 DbSeek(xFilial("GCS") + cCodLoc)
 
 DbSelectArea("GA7")
 DbSetOrder(1)
 DbSeek(xFilial("GA7") + cProSol)
 
 If !Empty(GA7->GA7_CODGPP)
 	
 	DbSelectArea("GAQ")
 	DbSetOrder(1)
 	DbSeek(xFilial("GAQ") + GA7->GA7_CODGPP)
 	
  If !Empty((cLocSol := Fs_RGrpSet(cProSol, GA7->GA7_CODGPP, lSelSetor)))
   lSolLau := GAQ->GAQ_SLAUDO == "1"
   lPerAlt := GCS->GCS_SLAUDO # "1" 		
  EndIf 	 	
 EndIf
 		
 If Hs_ExisDic({{"C","GM2_SLAUDO"}},.F.) 
  DbSelectArea("GM2")
  DbSetOrder(1) //GM2_FILIAL + GM2_CODLOC + GM2_CODPRO   
  lProcPer  := DbSeek(xFilial("GM2") + cCodLoc + cProSol)		
  lProcLaud := IIF(lProcPer, GM2->GM2_SLAUDO # "0", .T.)
  cLocSol   := IIF(lProcLaud, cLocSol, "")
  lSolLau   := lProcLaud
 		EndIf
 		
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return({lSolLau, lPerAlt, cLocSol, lProcPer})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Fs_RGrpSet ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna setor executante do laudo                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Código do setor executante do laudo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do procedimento                                 ³±±
±±³          ³ExpC2: Código do grupo de procedimento                        ³±±
±±³          ³ExpL3: Se seleciona setores relacionados a tabela GNQ         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_IsLaudo                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fs_RGrpSet(cCodPro,cGruPro, lSelSetor)
 Local aArea := getArea()
 Local cSql  := ""
 Local aHDados := {}, aCDados := {}, nUDados := 0
 Local nOpca := 0, nX := 0
 Local cRet  := ""

 cSql := " SELECT GAQ_CODLOC CODLOC, GCS_NOMLOC "
 cSql += "   FROM "+RetSqlName("GAQ")+" GAQ "
 cSql += "   JOIN "+RetSqlName("GCS")+" GCS ON GCS_FILIAL = '"+xFilial("GCS")+"' AND GCS.D_E_L_E_T_ <> '*' AND GCS_CODLOC = GAQ_CODLOC "
 cSql += "  WHERE GAQ_FILIAL = '"+xFilial("GAQ")+"' AND GAQ.D_E_L_E_T_ <> '*' AND GAQ_GRUPRO = '"+cGruPro+"' "           
	
	If lSelSetor .And. Hs_ExisDic({{"T", "GNQ"}},.F.)
	 cSql += "  UNION  "
	 cSql += " SELECT GNQ_CODLOC CODLOC, GCS_NOMLOC "
	 cSql += "   FROM "+RetSqlName("GNQ")+" GNQ "
	 cSql += "   JOIN "+RetSqlName("GCS")+" GCS ON GCS_FILIAL = '"+xFilial("GCS")+"' AND GCS.D_E_L_E_T_ <> '*' AND GCS_CODLOC = GNQ_CODLOC "
	 cSql += "  WHERE GNQ_FILIAL = '"+xFilial("GNQ")+"' AND GNQ.D_E_L_E_T_ <> '*' AND GNQ_GRUPRO = '"+cGruPro+"' "
 	EndIf
 	
	TCQUERY cSql NEW ALIAS "QRY" 
 
 DbSelectArea("QRY")
 
 DbGoTop()

 //Criando aHeader
 Aadd(aHDados, {" "             , "cRetSetor", "@BMP"  , 2                        , 0, ".F.", ""    , "C", "", "V" , "" , "","","V"})                          
 Aadd(aHDados, {"Cod Setor"     , "cCodLoc"  , "@!"    , TamSx3("GCS_CODLOC")[1] , 0, ".F.", ""    , "C", "", "V" , "" , "", "", "V"})
 Aadd(aHDados, {"Nome"          , "cNomLoc"  , "@!"    , TamSx3("GCS_NOMLOC")[1] , 0, ".F.", ""    , "C", "", "V" , "" , "", "", "V"})

 //Criando aCols
 While !QRY->(Eof())
  aAdd(aCDados, {"LBNO", QRY->CODLOC, QRY->GCS_NOMLOC, .F.})
  DbSkip() 
 EndDo    

 DbSelectArea("QRY")
 DbCloseArea()
 
 If Len(aCDados) > 1
  cTitulo := "Selecione Setor Executante para "
  If Type("GBY->GBY_SEQDES") # nil .And. !Empty(GBY->GBY_SEQDES)
   cTitulo += " - Despesa: "+GBY->GBY_SEQDES                                                             
  EndIf
  cTitulo += " Procedimento: "+cCodPro+"-"+Hs_IniPAdr("GA7", 1, cCodPro, "GA7_DESC",,.F.)
  
	 DEFINE MSDIALOG oDlg TITLE cTitulo From 000, 000 To 300, 500 Of oMainWnd Pixel   
	 
	  oGDGCS := MsNewGetDados():New(000, 000, 300, 500,0,,,,,,,,,, oDlg, aHDados, aCDados)
	  oGDGCS:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT    
	  oGDGCS:oBrowse:BlDblClick := { || FS_DbClik(oGDGCS) }
 		
	 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||nOpca := 1, IIF(!FS_VlRetSt(oGDGCS, 1), nOpca := 0, oDlg:End())}, {|| nOpca := 0, oDlg:End()})
	 
	 If nOpcA == 1
	  cRet := oGDGCS:aCols[aScan(oGDGCS:aCols, {| aVet | aVet[1] == "LBTIK"}), 2]
	 EndIf  
 ElseIf Len(aCDados) == 1
  cRet := aCDados[1, 2]
 EndIf
 		
 RestArea(aArea)
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_DbClik  ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que responde ao duplo clique em uma MsNewGetDados,     ³±±
±±³          ³utilizada para checar um campo do tipo 'marca'                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: MsNewGetDados que possui a coluna para marcar(LBTIK)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fs_RGrpSet                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/        
Static Function FS_DbClik(oObj)
Local nAt := 0
Local cMark := oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos]

While (nAt := aScan(oObj:aCols, {| aVet | aVet[1] == "LBTIK"})) > 0
	oObj:aCols[nAt, 1] := "LBNO"
End

If oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] $ "LBTIK/LBNO" .AND. Len(oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos]) <> 2
	oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] := IIF(cMark == "LBTIK", "LBNO", "LBTIK")
EndIf

oObj:Refresh()

Return(Nil)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VlRetSt ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se apenas um setor foi selecionado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se apenas um setor foi selecionado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: MsNewGetDados que possui a coluna para marcar(LBTIK)   ³±±
±±³          ³ExpN2: Posição da coluna de marca na MsNewGetDados            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fs_RGrpSet                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/        
Static Function FS_VlRetSt(oObj, nPos) 
 Local lRet := .T.
 Local nAt  := 0
                                                                                
 If     !(lRet := ((nAt := aScan(oObj:aCols, {| aVet | aVet[nPos] == "LBTIK"}))> 0))
  HS_MsgInf("Nenhum Setor selecionado.", "Atenção", "Validação Setor")  
 ElseIf !(lRet := (aScan(oObj:aCols, {| aVet | aVet[nPos] == "LBTIK"}, nAt+1) == 0))
  HS_MsgInf("Selecione apenas um setor.", "Atenção", "Validação Setor")   
 EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_SLaudo  ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que válida se despesa com procedimento pode ser        ³±±
±±³          ³alterada, de acordo com status do laudo, e também se o        ³±±
±±³          ³procedimento solicita laudo ou não.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se despesa com procedimento pode ser alterada.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Se a chamada da rotina partiu do linhaOk da            ³±±
±±³          ³       MsNewGetDados(oGDPR)                              (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_VProHon,HS_RecM24                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_SLaudo(lLinhaOk, cCodDes)
Local aLaudo := {}
Local cCodLoc := IIf(nPRCodLoc > 0 .And. !Empty(oGDPR:aCols[oGDPR:nAt, nPRCodLoc]), oGDPR:aCols[oGDPR:nAt, nPRCodLoc], cLctCodLoc)

Default cCodDes := ""
Default lLinhaOk := .F.

If !lLinhaOk
	DbSelectArea("GCZ")
	DbSetOrder(1) //GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
	If Empty(cGczNrSeqG) .Or. (DbSeek(xFilial("GCZ") + cGczNrSeqG) .And. GCZ->GCZ_STATUS # "2" )
		If !Empty(oGDPR:aCols[oGDPR:nAt, nPRSeqDes])
			DbSelectarea("GBY")
			DbSetorder(4)//GBY_FILIAL+GBY_SEQDES
			If DbSeek(xFilial("GBY") + oGDPR:aCols[oGDPR:nAt, nPRSeqDes])
				If GBY->GBY_STATUS <> "0"
					HS_MsgInf(STR0072,STR0003,STR0073) // "A Despesa não pode ser alterada. A solicitação de exame já está sendo processada."###"Atenção"###"Validação de Solicitação de Laudo - HS_SLaudo"
					Return(.F.)
				EndIf
			EndIf
		EndIf
	EndIf
End

If Empty(cCodDes)
	cCodDes := IIf(oGDPR:oBrowse:nColPos == nPRCodDes .And. !lLinhaOk, &("M->" + oGDPR:aHeader[nPRCodDes, 2]), oGDPR:aCols[oGDPR:nAt, nPRCodDes])
Endif

If nPRSLaudo > 0
	aLaudo     := HS_IsLaudo(cCodLoc, cCodDes)
	lGd7SLaudo := aLaudo[2]
	If !lLinhaOk
		oGDPR:aCols[oGDPR:nAt, nPRSLaudo] := IIf(aLaudo[1], "1", "0")
		oGDPR:aCols[oGDPR:nAt, nPRCrmLau] := IIf(!Empty(oGDGcz:aCols[oGDGcz:nAt, nGczCodCrm]), oGDGcz:aCols[oGDGcz:nAt, nGczCodCrm], oGDPR:aCols[oGDPR:nAt, nPRCrmLau])
		oGDPR:aCols[oGDPR:nAt, nPRNMeLau] := IIf(!Empty(oGDGcz:aCols[oGDGcz:nAt, nGczNomMed]), oGDGcz:aCols[oGDGcz:nAt, nGczNomMed], oGDPR:aCols[oGDPR:nAt, nPRNMeLau])
	EndIf
EndIf
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VExcLau ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Válida se despesa com procedimento pode ser excluida de acordo³±±
±±³          ³com o Status do Laudo.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se despesa pode ser excluida                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_RecM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VExcLau()

 Local lRet := .T.
 
 If nPRSLaudo > 0 
  If oGDPr:aCols[oGDPr:nAt, nPRSLaudo] == "1"   
  
   If !Empty(oGDPR:aCols[oGDPR:nAt, nPRSeqDes]) .And. Type("cGczNrSeqG") <> "U"
    DbSelectArea("GCZ")
    DbSetOrder(1) //GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
    If Empty(cGczNrSeqG) .Or. (DbSeek(xFilial("GCZ") + cGczNrSeqG) .And. GCZ->GCZ_STATUS # "2" )
     DbSelectarea("GBY")
     DbSetorder(4)//GBY_FILIAL+GBY_SEQDES
     If DbSeek(xFilial("GBY") + oGDPR:aCols[oGDPR:nAt, nPRSeqDes])
      If GBY->GBY_STATUS <> "0"
       HS_MsgInf(STR0074,STR0003,STR0075)//"A despesa não pode ser excluida. A solicitação de exame já está sendo processada."###
       lRet := .F.
      EndIf
     EndIf
    EndIf
   EndIf
  EndIf
 EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VIncide ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se procedimento tem incidencia e lanca ou não a linha  ³±±
±±³          ³da incidencia na MsNewGetDados do procedimento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo OK                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Quantidade digitada                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VIncide(nQtDigInc)

 Local lRet       := .T.
 Local cCodLoc    := IIf(nPRCodLoc > 0 .And. !Empty(oGDPR:aCols[oGDPR:nAt, nPRCodLoc]), oGDPR:aCols[oGDPR:nAt, nPRCodLoc], cLctCodLoc)
 Local dDatDes    := IIf(nPRDatDes > 0 .And. !Empty(oGDPR:aCols[oGDPR:nAt, nPRDatDes]), oGDPR:aCols[oGDPR:nAt, nPRDatDes], dDataBase)
 Local cHorDes    := IIf(nPRHorDes > 0 .And. !Empty(oGDPR:aCols[oGDPR:nAt, nPRHorDes]), oGDPr:aCols[oGDPr:nAt, nPrHorDes], Nil)
 Local cUrgDes    := IIf(nPRUrgDes > 0 .And. !Empty(oGDPR:aCols[oGDPR:nAt, nPRUrgDes]), oGDPr:aCols[oGDPr:nAt, nPRUrgDes], Nil)
 Local cCodCrm    := IIf(nPRCodCrm > 0 .And. !Empty(oGDPR:aCols[oGDPR:nAt, nPRCodCrm]), oGDPr:aCols[oGDPr:nAt, nPRCodCrm], Nil)
 Local cCodAto    := IIf(nPRCodAto > 0 .And. !Empty(oGDPR:aCols[oGDPR:nAt, nPRCodAto]), oGDPr:aCols[oGDPr:nAt, nPRCodAto], Nil)
 Local cOriDes    := IIf(nPROriDes > 0 .And. !Empty(oGDPR:aCols[oGDPR:nAt, nPROriDes]), oGDPr:aCols[oGDPr:nAt, nPROriDes], "0")
 Local cCodDes    := oGDPr:aCols[oGDPr:nAt, nPRCodDes]
 Local cSPrinc    := IIf(nPrSPrinc > 0 .And. !Empty(oGDPr:aCols[oGDPr:nAt, nPRSPrinc]), oGDPr:aCols[oGDPr:nAt, nPRSPrinc], StrZero(oGDPr:nAt, oGDPr:aHeader[nPRSPrinc, 4]))
 Local aRIncide   := {}
 Local nIncidProc := HS_IniPadr("GA7", 1, cCodDes, "GA7_INCIDE",,.F.)
 Local aTabPre    := HS_RTabPre("GC6", cGczCodPla, cCodDes, dDatDes)
 Local aClRProced := aClone (__aRProced)
 Local cCodPrInc  := ""            
 Local nRDes      := 0
 Local cFMntEqp   :=  __cFMntEqp
 Local nPIncide   := 0 //sera usado na HS_RValPr()
 
 __cFMntEqp := Nil // Nao ira chamar essa funcao. Precisa restaurar no final da funcao
  
 If cOriDes == "2" // 2-Incidencia
  
  HS_MsgInf(STR0065, STR0003, STR0066) //"Este campo da incidência não pode ser alterado"###"Atenção"###"Validação de Incidência"
  lRet:= .F.

 ElseIf lRet := (nQtDigInc > nIncidProc)// Qtde digitada e maior que a incidencia do procedimento ?
 	
 	nPIncide := aScan(oGDPr:aCols, {| aVet | aVet[nPRSPrinc] == cSPrinc .And. aVet[nPROriDes] == "2"})
 	
 	DbSelectArea("GAU")
 	DbSetOrder(2)
 	// Procura incidencia lancada anteriormente e se existe incidencia para o procedimento
 	If nPIncide == 0 .And. DbSeek(xFilial("GAU") + aTabPre[1] + GA7->GA7_CODGPP)
 	 oGDPr:AddLine(.F., .F.)
 	 oGDPr:lNewLine := .F.
 	 nPIncide := Len(oGDPr:aCols)
 	ElseIf nPIncide > 0 // Encontrou incidencia lancada anteriormente
 	 oGDPr:aCols[nPIncide, Len(oGDPr:aHeader) + 1] := .F.
 	EndIf 
 	
 	aAdd(__aRProced , {"oGDPR:aCols[oGDPR:nAt, nPRQTDDES]", "16, 01"})
 	
 	For nRDes := 1 To Len(__aRProced)
   __aRProced[nRDes, 1] := StrTran(__aRProced[nRDes, 1], "oGDPR:nAt", AllTrim(Str(nPIncide))) 
  Next
 	
 	cCodPrInc := HS_IniPadr("GAU", 2, aTabPre[1] + GA7->GA7_CODGPP, "GAU_CODPRO",,.F.)
 	// Existe incidencia e a validacao do procedimento nao encontrou nenhum problema
 	If (nPIncide > 0) .And. (lRet := HS_VProced(cGczCodPla, cGcsCodLoc, cCodPrInc,,, cHorDes, cUrgDes, cCodCrm, cCodAto, {cGcyAtendi, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO},, dDatDes, {GAU->GAU_FORVAL, cCodDes, nQtDigInc, nIncidProc}))
 	
   oGDPr:aCols[nPIncide, nPRCodDes] := cCodPrInc
   oGDPr:aCols[nPIncide, nPRDDespe] := HS_IniPadr("GA7", 1, oGDPr:aCols[nPIncide, nPRCodDes], "GA7_DESC",,.F.)
   oGDPr:aCols[nPIncide, nPRCodCrm] := cCodCrm
   oGDPr:aCols[nPIncide, nPRNomMed] := oGDPr:aCols[oGDPr:nAt, nPRNomMed]
   oGDPr:aCols[nPIncide, nPRSPrinc] := cSPrinc
   oGDPr:aCols[nPIncide, nPROriDes] := "2" // 2-Incidencia

  EndIf

 ElseIf lRet := (nQtDigInc = nIncidProc)
 	
  If (nPIncide := aScan(oGDPr:aCols, {| aVet | aVet[nPRSPrinc] == cSPrinc .And. aVet[nPROriDes] == "2"})) <> 0
   oGDPr:aCols[nPIncide, Len(oGDPr:aHeader) + 1]  := .T. 
   oGDPr:oBrowse:Refresh()
	 EndIf

 Else
 	HS_MsgInf(STR0067, STR0003, STR0066) //"A incidência informada deve ser maior que a incidência padrão do procedimento"###"Atenção"###"Validação de Incidência"
 EndIf

 If lRet .And. nPIncide > 0 // Esta tudo Ok e existe incidencia para o procedimento
  oGDPr:aCols[oGDPr:nAt, nPRSPrinc] := cSPrinc
 EndIf

 // Restaura o conteudo inicial
 __cFMntEqp := cFMntEqp 
 __aRProced := aClone(aClRProced)

Return(lRet)
                     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_DelInci³ Autor ³Luiz Pereira da Silva  ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Excluão do procedimento que gerou incidencia               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1: Se procedimento foi deletado                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_RecM24                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_DelInci()
 Local lRet     := .T.
 Local cSPrinc  := ""
 Local nPIncide := 0
 
 If oGDPr:aCols[oGDPr:nAt, nPROriDes] <> "2" // 2-Incidencia
  cSPrinc := IIf(!Empty(oGDPr:aCols[oGDPr:nAt, nPRSPrinc]), oGDPr:aCols[oGDPr:nAt, nPRSPrinc], StrZero(oGDPr:nAt, oGDPr:aHeader[nPRSPrinc, 4]))
  If (nPIncide := aScan(oGDPr:aCols, {| aVet | aVet[nPRSPrinc] == cSPrinc .And. aVet[nPROriDes] == "2"})) <> 0
   If !oGDPr:aCols[nPIncide, Len(oGDPr:aHeader) + 1] //Nao esta deletado
    oGDPr:aCols[nPIncide, Len(oGDPr:aHeader) + 1]  := .T.
   Else 
    HS_VIncide(oGDPr:aCols[oGDPr:nAt, nPRIncide])
   EndIf
   oGDPr:aCols[nPIncide, nPrStaReg] := oGDPr:aCols[oGDPr:nAt, nPrStaReg]
  EndIf
 Else
  lRet := .F.
 EndIf
 
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_M24LocK ³ Autor ³ Gestão Hospitalar      ³ Data ³15.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna código do setor da MsNewGetDados de medicamentos(oGDMM)³±±
±±³          ³Caso esse seja vazio, retorna o código do setor do atendimento ³±±
±±³          ³ou do orçamento dependendo do Alias                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Código do Setor                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_VldM19,HS_VldM24,FS_CopyOrc                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M24LocK(cAlias)
 Local cCodLoc := IIF(cAlias $ "GO5/GO6/GO7", M->GO0_CODLOC, M->GCY_CODLOC)

 If ValType(nMMCodLoc) # "U" .and. nMMCodLoc > 0 .and. !Empty(oGDMM:aCols[oGDMM:nAt, nMMCodLoc])
 	cCodLoc := oGDMM:aCols[oGDMM:nAt, nMMCodLoc]
 EndIf
Return(cCodLoc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VldGB2  ³ Autor ³ Mario Arizono         ³ Data ³17.10.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida pediatra do recem nascido da tabela GB2                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se pediatra existe na tabela SRA                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Dicionário de Dados(SX3)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldGB2()
Local lRet := .T.

If ReadVar() == "M->GB2_CODPED"
	If !HS_SeekRet("SRA","M->GB2_CODPED",11,.f.,"GB2_NOMPED","RA_NOME")
		HS_MsgInf(STR0018,STR0003,STR0068)  //"CRM do Medico Pediatra Invalido"###"Atencao" //"Valida pediatra do recem nascido"
		lRet := .F.
	EndIf
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_INomLoc ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna do nome do setor para inicialização dos campos        ³±±
±±³          ³virtuais que sejam destinados a apresentar o nome do setor    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Nome do setor                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela que terá o campo inicializado          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Dicionário de Dados(SX3)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_INomLoc(cAlias)
Local cNomLoc := Space(HS_CfgSx3("GD5_NOMLOC")[SX3->(FieldPos("X3_TAMANHO"))])
Local cCodLoc := "M->" + cAlias + "_CODLOC"

cCodLoc := IIf(Type(cCodLoc) <> "U" .And. !Empty(&(cCodLoc)), &(cCodLoc), cLctCodLoc)

cNomLoc := HS_IniPadr("GCS", 1, cCodLoc, "GCS_NOMLOC",, .F.)

Return(cNomLoc)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±       
±±ºPrograma  ³HS_GEndProº Autor ³ Marcelo Jose       º Data ³  20/02/06   º±±
±±ºAlteracao ³          º       ³ Antonio Carlos     º Data ³  24/05/06   º±±
±±ºAlteracao ³          º       ³ Antonio Carlos     º Data ³  06/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ gera relacionamento prontuario endereco para o SPP         º±±
±±ºAlteracao ³ enderecamento automatico de prontuarios                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

                     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_GEndPro ³ Autor ³ Marcelo Jose          ³ Data ³20.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera enderecamento automatico  de prontuarios para o SPP      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do Setor                                        ³±±
±±³          ³ExpC2: Código do Prontuário                                   ³±±
±±³          ³ExpC3: Tipo do Setor                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FS_GrvM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function HS_GEndPro(cSetor,cRegger,cTipLoc)
	Local aArea := GetArea(), cTipEnd := "", cEndTip := "", cCodEnd := ""
	Local lLocReg := .T. //Indica se o registro esta locado para outro usuario //

	// Localiza informacoes atraves do setor: Tipo de Endereco e Controle //
	GCS->(DbSetOrder(1))
	GCS->(DbSeek(xFilial("GCS") + cSetor))
	cEndTip := GCS->GCS_ENDTIP  
	cTipEnd := IIF(GCS->GCS_TIPLOC == "0", "3", IIF(GCS->GCS_TIPLOC == "1", "1", IIF(GCS->GCS_TIPLOC == "2" , "2", "")))
	If Empty(cTipEnd)
 	cTipEnd := IIF(cTipLoc == "0", "3", IIF(cTipLoc == "1", "1", IIF(cTipLoc == "2", "2", "")))
	EndIf

	//Checa se Setor faz Enderecamento (caso seja informado o Tipo de Endereco) //
	If !Empty(cEndTip)   
	
		//Se enderecar por multi-prontuario(0) mas se o CODEND nao esta informado na tabela de setor, nao vai poder enderecar //
		If (cEndTip == "0")    
			If Empty(GCS->GCS_CODEND)
				Return(Nil)
			Else
		 	cCodEnd := GCS->GCS_CODEND
			EndIf
		EndIf
	 
		//Verificar se ja existe enderecamento cadastrado para Multi-Prontuario/Pasta e Terminacoes, se existir Sai Fora(Retorna).	
		cQuery  := "SELECT GSB.GSB_CODEND GSB_CODEND
		cQuery  += " FROM " + RetSqlName("GSB") + " GSB "
		cQuery  += " JOIN " + RetSQLName("GSD") + " GSD ON GSD.GSD_CODEND = GSB.GSB_CODEND "
		cQuery  += " AND GSD.GSD_FILIAL = '" + xFilial( " GSD " ) + "' AND GSD.D_E_L_E_T_ <> '*' "
		cQuery  += " AND GSD.GSD_EATIVO = '0'"
		cQuery  += " WHERE "
		cQuery  += " GSB.GSB_FILIAL = '" + xFilial( " GSB " ) + "' AND "
		cQuery  += " GSB.D_E_L_E_T_ <> '*' AND "
		cQuery  += " GSB.GSB_REGGER = '" + cRegGer + "' "
		If GCS->GCS_ENDTIP == "0"        	// Multi-Prontuario
			cQuery += " AND GSD.GSD_ENDTIP = '0' " 
			cQuery += " AND GSD.GSD_TIPEND = '" + cTipEnd + "' "
		ElseIf GCS->GCS_ENDTIP == "1"    // Pasta
			cQuery += " AND GSD.GSD_ENDTIP = '1' "
			cQuery += " AND GSD.GSD_TIPEND = '" + cTipEnd + "' "
		ElseIf GCS->GCS_ENDTIP == "2"    // Terminacoes
			cQuery += " AND GSD.GSD_ENDTIP = '2' " 
			cQuery += " AND GSD.GSD_TIPEND = '" + cTipEnd + "' "
		EndIf
		cQuery  += "ORDER BY GSB.GSB_CODEND"
	
		cQuery  :=  ChangeQuery(cQuery)
		TCQUERY cQuery NEW ALIAS "QRY"
		DbSelectArea("QRY")
		If !Eof()
			DbCloseArea()
			RestArea(aArea)
			Return(Nil)
		EndIf
		DbCloseArea()
	
		// Se nao existir atribui endereco - Pasta/Terminacao (nao foi enderecado procura endereco) //
		
		If (cEndTip <> "0") //Multi-prontuario
	 	cQuery    := "SELECT "
	 	cQuery    += "GSD.GSD_CODEND GSD_CODEND "
	 	cQuery    += "FROM "+RetSqlName("GSD") + " GSD "
	 	cQuery    += "WHERE "
	 	cQuery    += "GSD.GSD_FILIAL = '" + xFilial( "GSD" ) + "' AND "
	 	cQuery    += "(GSD.GSD_ENDTIP = '" + cEndTip + "' OR GSD.GSD_ENDTIP = '" + Space(Len(GSD->GSD_ENDTIP)) + "') AND "
	 	cQuery    += "GSD.GSD_EATIVO = '0' AND "
	 	If (cEndTip == "1")                           // Pasta
		 	cQuery   += "GSD.GSD_STATUS = '0' AND "
	 	ElseIf (cEndTip == "2")                       // Terminacao
	 		cQuery   += "GSD.GSD_TERMIN = '" + SUBSTR(cRegGer,6,1) + "' AND "
	 		cQuery   += "GSD.GSD_TIPEND = '" + cTipEnd + "' AND "
	 	EndIf
	 	cQuery    += "GSD.D_E_L_E_T_ <> '*' "
	 	cQuery    += "ORDER BY GSD.GSD_CODEND"
	 	cQuery    := ChangeQuery(cQuery)
	 	TCQUERY cQuery NEW ALIAS "QRY"
	 	DbSelectArea("QRY")
	 	If Eof()
	 		dbCloseArea()
				RestArea(aArea)
	 		Return(Nil)
	 	Endif  
	  
			While !Eof() .And. lLocReg
	  	cCodEnd := QRY->GSD_CODEND
	 	
   	// Verifica se o registro esta bloqueado (pasta), caso nao esteja, entao bloqueia //
 			If (cEndTip == "1")
					lLocReg := !LockByName("A95GSD" + cCodEnd, .T., .T., .F.)
					cCodEnd := IIf(lLocReg, CriaVar("GSD_CODEND", .F.), cCodEnd)
 			Else
 				lLocReg := .F.
 			EndIf
 			
 			DbSelectArea("QRY")
 			dbSkip()
	 	EndDo
	 	
	 	dbCloseArea()
		Endif
	 
	 // cCodEnd vazio indica que não foi encontrado um endereco para ser locado o prontuario //
	 If Empty(cCodEnd)
				RestArea(aArea)
	 		Return(Nil)
	 EndIf
	
		// Localiza endereco na GSD - CAD.ENDERECOS DE PRONTUARIOS e altera conforme Tipo de Endereco //
		DbSelectArea("GSD")
		DbSetOrder(1)
		If !DbSeek(xFilial("GSD") + cCodEnd )
			RestArea(aArea)
			Return(Nil)
		Else
			RecLock("GSD", .F.)
				If Empty(GSD->GSD_ENDTIP)
					GSD->GSD_ENDTIP := cEndTip
				EndIf
	
				If 					(GCS->GCS_ENDTIP == "1")	// Pasta
					GSD->GSD_STATUS := "1"
 				GSD->GSD_TIPEND := cTipEnd
				ElseIf 	(GCS->GCS_ENDTIP == "2")	// Terminacao
					GSD->GSD_TERMIN := SUBS(M->GCY_REGGER,6,1)
				EndIf
			MsUnLock()
		
			RecLock("GSB", .T.)
				GSB->GSB_REGGER := cRegger
				GSB->GSB_CODEND := cCodEnd
				GSB->GSB_DESEND := HS_IniPadr("GSD", 1, cCodEnd, "GSD_DESEND",, .F.)
				GSB->GSB_TIPEND := cTipEnd
				GSB->GSB_LOGARQ := HS_LOGARQ()
			MsUnLock()
			
			UnLockByName("A95GSD" + cCodEnd, .T., .T., .F.)
		EndIf
	
	EndIf

RestArea(aArea)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VDatDes ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Data e hora da despesa, não permitindo lançar com data ³±±
±±³          ³e hora menor que a data e hora do atendimento e e nem maior   ³±±
±±³          ³que a data e hora da alta, caso o atendimento ainda nao tenha ³±±
±±³          ³alta considera a data base e a hora atual do sistema          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se despesa pode ser lançada ou não                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Data da despesa                                        ³±±
±±³          ³ExpC2: Hora da despesa                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_RecM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VDatDes(dDatDes, cHorDes)
 Local lRet := .T.
 
  cHorDes := SUBSTR(cHorDes, 1, 5)
 	
 	If     !(lRet :=  dDatDes >= M->GCY_DATATE)
 		HS_MsgInf(STR0083 + " [" + DToC(dDatDes) + "] " + " [" + DToC(M->GCY_DATATE) + "]", STR0003, STR0085) //"A data do lançamento da despesa###não pode ser menor que a data do atendimento###"Atenção"###"Lançamento de despesas"
 		
 	ElseIf !(lRet := IIf(!Empty(M->GCY_DATALT), dDatDes <= M->GCY_DATALT, .T.))
 		HS_MsgInf(STR0083 + " [" + DToC(dDatDes) + "] " + STR0086 + " [" + DToC(M->GCY_DATALT) + "]", STR0003, STR0085)//"A data do lançamento da despesa###não pode ser maior que a data da alta do atendimento###"Atenção"###"Lançamento de despesas"
 		
 	ElseIf !(lRet := dDatDes <= dDataBase)
 		HS_MsgInf(STR0083 + " [" + DToC(dDatDes) + "] " + STR0087 + " [" + DToC(dDataBase) + "]", STR0003, STR0085)//A data do lançamento da despesa###não pode ser maior que a data base do sistema###"Atenção"###"Lançamento de despesas"
 	EndIf
 	
 	If !HS_VldHora(cHorDes)
 	 HS_MsgInf(STR0088 + " [" + cHorDes + "] " + STR0089, STR0003, STR0085)//"A hora do lançamento da despesa###deve estar ente 00:00 e 23:59.###"Atenção"###"Lançamento de despesas"
 	 lRet := .F.
 	ElseIf dDatDes == M->GCY_DATATE .AND. cHorDes < SUBSTR(M->GCY_HORATE, 1, 5)                                                                                               
 	 HS_MsgInf(STR0090 + " [" + DToC(dDatDes) + "] " + STR0091 + " [" + cHorDes + "] " + STR0092 + " [" + M->GCY_HORATE + "].", STR0003, STR0085)//"Na Data"###a hora do lançamento da despesa###não pode ser menor que a hora do atendimento###"Atenção"###"Lançamento de despesas" 	
 	 lRet := .F.
 	EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_IniGSUS ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função para lançamento automático dos código de tipo de       ³±±
±±³          ³atendimento e grupo de atendimento                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de despesa selecionada                 ³±±
±±³          ³ExpC2: Número sequencial da guia                              ³±±
±±³          ³ExpC3: Código do plano                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_RecM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_IniGSUS(cAlias, cNrSeqG, cCodPla)
 Local aArea 			  := GetArea()
 Local cPref 			  := cAlias + "->" + PrefixoCpo(cAlias)
 Local nColP				  := 2
 Local cTpPla     := 0
 Local aVetPro 	  := {}
 Local cGCdGate := "", cGCdTate := "", cGCodCid := ""
 Local cCodFEta   := "", cCodPro  := "" 

 If (cTpPla := IIf(cCodPla == __cCodBPA, "1", IIf(cCodPla == __cCodPAC, "2", "3"))) $ "1/2"

  DbSelectArea(cAlias)
  DbSetOrder(2) /* _FILIAL + _NRSEQG + DTOS(_DATDES) + _HORDES */
  DbSeek(xFilial(cAlias) + cNrSeqG)

  Begin Transaction

  While !Eof() .And. &(cPref + "_FILIAL") == xFilial(cAlias) .And. &(cPref + "_NRSEQG") == cNrSeqG
	  cCodPro := &(cPref + "_CODDES")
	  cCodFEta := HS_FEtaria(&(cPref + "_REGATE"))
	  aVetPro := HS_IniPSUS(cCodPro, cCodFEta)
	
	  RecLock(cAlias, .F.)
	
	  If cTpPla $ "1/2"
		
  		
  		If cTpPla == "1"
   		If Empty(cGCdGate := &(cPref + "_CDGATE"))
   			&(cPref + "_CDGATE") := aVetPro[2][1]
   		EndIf
   		If Empty(cGCdTate := &(cPref + "_CDTATE"))
   			&(cPref + "_CDTATE") := aVetPro[3][1]
   		EndIf
   	
   	Endif	
		
  	Endif
	  MsUnLock()
	  
 		If cTpPla == "1" .And. Empty(GCZ->GCZ_NRGUIA)
 		 RecLock("GCZ", .F.)
 		  GCZ->GCZ_NRGUIA := "BPA" + GCZ->GCZ_REGATE
 		  If ValType("cGuiaBpa") <> "U"
 		  	cGuiaBpa := GCZ->GCZ_NRGUIA
 		  EndIf 
 		 MsUnLock()
 		Endif 
	
	  DbSkip()
  EndDo

  End Transaction
 Endif

 RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_InicSUSºAutor  ³Eduardo Alves       º Data ³  05/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que inicializa os campos do SUS caso estejam vazio.  º±±
±±º          ³Utilizando a funcao HS_IniPadr()                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

cCodPro  =	Codigo do Procedimento
cIdade   = Idade do Paciente (Ex.: 74a05m10d)
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_IniPSUS ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna grupo e o tipo de atendimento de acordo com o         ³±±
±±³          ³procedimento e com a faixa etária                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com o código do Grupo do Atendimento e com Tipo  ³±±
±±³          ³       Atendimento                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do Procedimento                                 ³±±
±±³          ³ExpC2: Código da faixa etária                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_IniGSUS,HS_RValPr,FS_GravREL                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_IniPSUS(cCodPro, cCodFEta)

 Local aArea 				:= GetArea()
	Local aVetPro 		:= {}
 Local cPCdGate := "", cPCdTate := ""

 aAdd(aVetPro, 	 {	"",	""}	)

	cPCdGate := HS_RetGAte(cCodPro, cCodFEta)[1]
	aAdd(aVetPro, 	 {	cPCdGate,	HS_IniPadr("GH3", 1, cPCdGate, "GH3_DSGATE",, .F.)}	) 	//* Grupo de Atendimento 			*/
	
	cPCdTate := HS_IniPadr("GHG", 1, cCodPro, "GHG_CDTATE",, .F., "GHG_CODPRO")
	aAdd(aVetPro, 	 {	cPCdTate,	HS_IniPadr("GH4", 1, cPCdTate, "GH4_DSTATE",, .F.)}	) 	//* Tipo de Atendimento 				*/

	RestArea(aArea)

Return(aVetPro)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VldVal  ³ Autor ³ Daniel Peixoto        ³ Data ³30.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que valida se o valor da despesa > valor do campo      ³±±
±±³          ³GC1_VALMAT/GC1_VALMED/GC1_VALPRO                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tipo da validação                                      ³±±
±±³          ³       "MM" - Materiais e Medicamentos                        ³±±
±±³          ³       "PR" - Procedimentos                                   ³±±
±±³          ³ExpC2: Código da despesa                                      ³±±
±±³          ³ExpN3: Posição do campo VALDES na MsNewGetDados               ³±±
±±³          ³ExpA4: Array com os campos da Vigência do Plano               ³±±
±±³          ³       [1] GC1_VALMAT                                         ³±±
±±³          ³       [2] GC1_VALMED                                         ³±±
±±³          ³       [3] GC1_VALPRO                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_VldAuto                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                      
Static Function FS_VldVal(cTipo, cCodDes, nValDes, aRValGC1)
Local aAreaOld := GetArea()
Local lRet     := .F.
Local nValGC1  := 0

If nValDes > 0 //Faz se achou o valor da despesa
	If cTipo == "MM" //Mat/Med.
		DbSelectArea("GBI")
		DbSetOrder(1) //GBI_PRODUT
		DbSeek(xFilial("GBI") + cCodDes)
		If GBI->GBI_TIPO == "0" //Mat
			nValGC1 := aRValGc1[1][1]
		ElseIf GBI->GBI_TIPO == "1"  //Med
			nValGC1 := aRValGc1[2][1]
		EndIf
	Else //Proced.
		nValGC1 := aRValGc1[3][1]
	EndIf
	
	If nValGC1 <> 0
		lRet := nValDes > nValGC1
	EndIf
	
EndIf
 RestArea(aAreaOld)


Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_APGAR   ³ Autor ³ Antonio Carlos        ³ Data ³30.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que valida GB2 para APGAR e APGAR2 <> 0 quando Nativivo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: APGAR e APGAR2 com valores válidos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: MsNewGetDados dos recém-nascidos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_RNAM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_APGAR(oGetGB2)

	Local lRet  :=.T.
 Local nLnt  := 0
 Local nLin  := 0
	Local aArea := GetArea()

 For nLnt := 1 to Len(oGetGB2:aCols)
  If oGetGB2:aCols[nLnt, nGB2STNASC] == "1"
   If oGetGB2:aCols[nLnt, nGB2APGAR] == 0 .Or. oGetGB2:aCols[nLnt, nGB2APGAR2] == 0
    nLin++
   EndIf
  EndIf 
 Next                  

 If nLin > 0
  HS_MsgInf(STR0062, STR0003, STR0032) //"Por Favor, informe os valores dos campos relacionados ao APGAR."###"Atenção" //"Autorização de Materiais/medicamentos"
  nLin:=0
 	lRet:=.F.
 EndIf
  
 RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VPlaSet ³ Autor ³ Luiz Pereira S. Jr.   ³ Data ³02.02.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que verifica se o plano e permitido no Setor.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se plano é permitido no setor                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do Setor                                        ³±±
±±³          ³ExpC2: Código do Plano                                        ³±±
±±³          ³ExpL3: Se exibe mensagem de erro                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_VldM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VPlaSet(cCodLoc, cCodPla, lMensagem)

 Local aArea := GetArea()
 Local lRet := .T.
 
 DbSelectArea("GM0")
 DbSetOrder(1) //GM0_FILIAL+GM0_CODLOC+GM0_CODPLA
 If DbSeek(xFilial("GM0") + cCodLoc + cCodPla) // Se achar eh pq o plano nao eh permitido
  If lMensagem
   HS_MsgInf(STR0069 + cCodPla + STR0070 + cCodLoc + "]", STR0003, STR0071) // "Plano ["###"]não permitido no Setor ["###"Validação de Plano X Setor"
  EndIf
  lRet := .F.
 EndIf

 RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RetGAte ³ Autor ³ Gestão Hospitalar     ³ Data ³15.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna grupo de atendimento e se tem relacionamento com a    ³±±
±±³          ³faixa etária, de acordo com o procedimento                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo o código do grupo de atendimento e se há³±±
±±³          ³       relacionamento com a faixa etária                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do procedimento                                 ³±±
±±³          ³ExpC2: Código da faixa etária                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_IniPSUS, HS_VldM24                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RetGAte(cCodPro, cCodFEta)
 Local aAreaOld := GetArea()
 Local cCDGAte  := ""
 Local lCdFEta  := .F.
 
 DbSelectArea("GHC")
 DbSetOrder(1)
 If DbSeek(xFilial("GHC") + cCodFEta + cCodPro)
  cCDGAte := GHC->GHC_CDGATE
  lCdFEta := .T.
 Else
  cCDGAte := HS_IniPadr("GHF", 1, cCodPro, "GHF_CDGATE",, .F., "GHF_CODPRO")
 EndIf

 RestArea(aAreaOld)
Return({cCDGAte, lCdFEta})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_TemRN   ³ Autor ³ Gestão Hospitalar     ³ Data ³14.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna se atendimento possui recém-nascidos ou não           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se tem recém-nascido                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Registro de atendimento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM24                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_TemRN(cRegAte)
 Local lRet := .F.
 
 lRet := (HS_CountTB("GB2", "GB2_REGATE  = '" + cRegAte + "'")  > 0)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Hs_InVguF  ³ Autor ³ Bruno S. P. Santos    ³ Data ³11.07.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que Inicializa o campo GCZ_VGUIAF(Data Final de        ³±±
±±³          ³Validade da guia, quando o atendimento for SUS APAC)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpD1: Data final da validade                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Dicionário de Dados(Sx3)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Hs_InVguF()
 local dRet
 
 //If !Empty(nMv_VldGui)
  If !Empty(GCZ->GCZ_VGUIAI)
   dRet := GCZ->GCZ_VGUIAI + IIf(Type("nMv_VldGui") <> "U", nMv_VldGui, 0)
  ElseIf !Empty(M->GCY_DATATE)
   dRet := GCY->GCY_DATATE + IIf(Type("nMv_VldGui") <> "U", nMv_VldGui, 0)
  Else
   dRet := dDataBase + IIf(Type("nMv_VldGui") <> "U", nMv_VldGui, 0)
  EndIf
 //EndIf
 
Return(dRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Hs_NomeRn  ³ Autor ³ Bruno S. P. Santos    ³ Data ³09.08.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que preenche nome do Rn, na MsNewGetDados(oGetGB2),    ³±±
±±³          ³de acordo com o tipo de nascimento do RN                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Dicionário de Dados(Sx3)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Hs_NomeRn()
 If !Empty(M->GB2_TPNASC)
   oGetGB2:aCols[oGetGB2:oBrowse:nAt, nNomeRn] := "RN "+ IIF(M->GB2_TPNASC # "0","(" + M->GB2_TPNASC +") " ,"")+AllTrim(M->GCY_NOME)
 EndIf
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Fs_GetGMX  ³ Autor ³ Bruno S. P. Santos    ³ Data ³03.09.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que Retorna próximo número do intervalo de numeração   ³±±
±±³          ³das guias do TISS                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Próximo número do intervalo                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do Convênio                                     ³±±
±±³          ³ExpC2: Código do Tipo de Guia                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fs_GetGMX,HS_IniTISS                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fs_GetGMX(cCodConv, cTgTiss)
 Local aArea := getArea()
 Local cRet  := ""
 
 If !HS_ExisDic({{"T","GMX"},{"T","GMZ"}})
  return(TamSx3("GCZ_NRGUIA")[1])
 EndIf
 
 DbSelectArea("GMZ")
 DbSetOrder(2)//GMZ_FILIAL+GMZ_CODCON+GMZ_TGTISS
 If DbSeek(xFilial("GMZ")+cCodConv+cTgTiss)
 
  If LockByName("FUM24GMX" + cCodConv + cTgTiss + GMZ->GMZ_CODSEQ + Str(GMZ->GMZ_INTERV), .T., .T., .F.)
   Begin Transaction 
    cRet := Str(GMZ->GMZ_INTERV)    
  
    RecLock("GMZ", .F.)
     DbDelete()
    MsUnlock()  
   End Transaction
   UnLockByName("FUM24GMX" + cCodConv + cTgTiss + GMZ->GMZ_CODSEQ + Str(GMZ->GMZ_INTERV), .T., .T., .F.)
  Else 
   Return(Fs_GetGMX(cCodConv, cTgTiss))
  EndIf 
 Else
  DbSelectArea("GMX")
  DbSetOrder(2)//GMX_FILIAL+GMX_CODCON+GMX_TGTISS+GMX_SITINT
  If DbSeek(xFilial("GMX")+cCodConv+cTgTiss+"1")
   If LockByName("FUM24GMX" + cCodConv + cTgTiss + GMX->GMX_CODSEQ + Str(GMX->GMX_INTPRO), .T., .T., .F.)
    Begin Transaction 
     cRet := Str(GMX->GMX_INTPRO)
     Fs_DecGMX(GMX->GMX_CODCON, GMX->GMX_CODSEQ, GMX->GMX_TGTISS)
    End Transaction
    UnLockByName("FUM24GMX" + cCodConv + cTgTiss + GMX->GMX_CODSEQ + Str(GMX->GMX_INTPRO), .T., .T., .F.)
   Else 
    Return(Fs_GetGMX(cCodConv, cTgTiss))
   EndIf
  EndIf
 EndIf            
 
 cRet := IIF(Empty(cRet),Space(TamSx3("GCZ_NRGUIA")[1]),AllTrim(cRet))
 
 RestArea(aArea)
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Fs_DecGMX  ³ Autor ³ Bruno S. P. Santos    ³ Data ³03.09.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que Atualiza o campo "Próximo" na GMX e válida se ainda ³±±
±±³          ³possui números disponiveis no intervalo.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do convênio                                      ³±±
±±³          ³ExpC2: Código sequencial do controle de guias por convênio(GMX)³±±
±±³          ³       por referência.                                         ³±±
±±³          ³ExpA3: Array com os campos que aparecerão na enchoice,         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fs_GetGMX                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fs_DecGMX(cCodConv, cSeqNum, cTgTiss)
 Local aArea := getArea()
 
 DbSelectArea("GMX")                
 DbSetOrder(1)//GMX_FILIAL+GMX_CODCON+GMX_CODSEQ+GMX_TGTISS
 If DbSeek(xFilial("GMX")+cCodConv+cSeqNum+cTgTiss)
  RecLock("GMX",.F.)
   If (GMX->GMX_INTPRO > 0) .And. (GMX->GMX_INTPRO <= GMX->GMX_INTFIN)
    GMX->GMX_INTPRO += 1
   Endif
 
   If(GMX->GMX_INTPRO > GMX->GMX_INTFIN) .Or. (GMX->GMX_INTPRO == 0 .And. GMX_SITINT == "1")
    GMX->GMX_INTPRO :=  0   
    GMX->GMX_SITINT := "0"
   EndIf
  MsUnLock() 
 EndIf          
 
 RestArea(aArea)
Return()                 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Fs_AddGMZ  ³ Autor ³ Bruno S. P. Santos    ³ Data ³03.09.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que adiciona número da guia na GMZ (Numeração          ³±±
±±³          ³Reutilizavel)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do convênio                                     ³±±
±±³          ³ExpC2: Código do tipo de guia                                 ³±±
±±³          ³ExpC3: Intervalo da numeração                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_ReutGui, HS_DelNrGT                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fs_AddGMZ(cCodConv, cTgTiss, cIntervalo)
 Local aArea := getArea()
 Local cSql  := "" 
 
 If Empty(cIntervalo) .Or. !HS_ExisDic({{"T","GMX"},{"T","GMZ"}})
  return(nil)
 EndIf                 
 cSql := " SELECT GMX_CODSEQ "   
 cSql += "   FROM "+RetSqlName("GMX")+" GMX"
 cSql += "  WHERE GMX.GMX_CODCON = '"+cCodConv+"' " 
 cSql += "    AND GMX.GMX_TGTISS = '"+cTgTiss+"' " 
 cSql += "    AND '"+cIntervalo+"' BETWEEN GMX_INTINI AND GMX_INTFIN "
 cSql += "    AND GMX.GMX_FILIAL = '"+xFilial("GMX")+"' AND GMX.D_E_L_E_T_ <> '*' "
  
 cSql := ChangeQuery(cSql)
 
 TCQUERY cSQL NEW ALIAS "QRYGMX"
 
 DbSelectArea("QRYGMX")
 DbGoTop() 
 
 If !QRYGMX->(EoF())
  cCodSeq := QRYGMX->GMX_CODSEQ
  
  DbSelectArea("GMZ")
  DbSetOrder(1)//GMZ_FILIAL+GMZ_CODCON+GMZ_TGTISS
 
  RecLock("GMZ",.T.)
   GMZ->GMZ_FILIAL := xFilial("GMZ")
   GMZ->GMZ_CODCON := cCodConv
   GMZ->GMZ_TGTISS := cTgTiss
   GMZ->GMZ_CODSEQ := cCodSeq
   GMZ->GMZ_INTERV := val(cIntervalo)
  MsUnlock() 
 EndIf
 
 DbSelectArea("QRYGMX")
 DbCloseArea()

 RestArea(aArea)
return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_ReutGui ³ Autor ³ Bruno S. P. Santos    ³ Data ³03.09.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ão ³Rotina que lê vetor de guias do TISS e marca como reutilizavel³±±
±±³          ³quando está for deletada ou quando o atendimento for cancelado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se reutilizar o número da guia funcionou               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Se foi dado Ok ou Cancelar na tela de atendimento      ³±±
±±³          ³       0 - Cancelar                                           ³±±
±±³          ³       1 - Ok                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_RecM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_ReutGui(nOpcA)
 Local aArea    := getArea()
 Local nContGcz := 0

 If !HS_ExisDic({{"C","GCZ_ALTGUI"},{"C","GCU_TATISS"},{"C","GCU_TIPCON"}}, .F.)
  return(.T.)
 EndIf

	For nContGcz := 1 to Len(aGuiaTiss)
	 if (Empty(aGuiaTiss[nContGcz, 5]).And. (nOpcA == 0)) .Or. aScan(oGDGcz:aCols,{|aVet| aVet[nGczNrSeqG] == aGuiaTiss[nContGcz, 5] .And. aVet[len(oGDGcz:aHeader)+1]}) > 0
   Fs_AddGMZ(aGuiaTiss[nContGcz, 2],aGuiaTiss[nContGcz, 3], aGuiaTiss[nContGcz, 4]) 
	 EndIf
	Next nContGcz
 RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_IniTISS ³ Autor ³ Bruno S. P. Santos    ³ Data ³03.09.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que inicializa campo do TISS na guia do atendimento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Número sequencial do TISS para o campo  número         ³±±
±±³          ³       da guia(GCZ_NRGUIA)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opç]ao escolhida para inicialização dos campos         ³±±
±±³          ³       3 - Inclusão                                           ³±±
±±³          ³       4 - Alteração                                          ³±±
±±³          ³ExpN2: Posição da guia incluida/alterada na MsNewGetDados     ³±±
±±³          ³ExpC3: Código do plano                                        ³±±
±±³          ³ExpC4: Código do tipo da guia                                 ³±±
±±³          ³ExpC5: Sequencial da guia                                (OPC)³±±
±±³          ³ExpA6: Array com os campos do header da MsNewGetDados da Guia ³±±
±±³          ³ExpA7: Array com o conteúdos das colunas da MsNewGetDados     ³±±
±±³          ³       da Guia                                           (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_IGuiaP,HS_RecM24,HS_VldM24,HS_M24Agd                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_IniTISS(nOpcTiss, nAtGcz, cCodPla, cTpgCod, cNrSeqG, aHeaderGCZ, aColsGCZ)
 Local aArea      := getArea()
 Local cNrGuia    := Space(TamSx3("GCZ_NRGUIA")[1]), cGcuTgTISS := "", cCodCon := ""
 Local lGuiaTiss  := .T.   
 Default cNrSeqG  := ""
 Default aColsGCZ := Nil

 If !HS_ExisDic({{"C","GCZ_ALTGUI"},{"C","GCU_TATISS"},{"C","GCU_TIPCON"}}, .F.)
  return(cNrGuia)
 EndIf

 cGcuTgTISS := HS_IniPadr("GCU", 1, cTpgCod, "GCU_TGTISS",,.F.)
 cCodCon    := HS_IniPadr("GCM", 2, cCodPla, "GCM_CODCON",,.F.)
 
 //Inicializando Numero Sequencial TISS 
 If (!Empty(cCodCon)).And.(!Empty(cGcuTgTISS))
	 If nOpcTiss == 3 
	  cNrGuia := FS_GETGMX(cCodCon, cGcuTgTISS)
	 Else
	  cNrGuia := aColsGCZ[nAtGcz, nGCZNrGuia]  
	  lGuiaTiss := HS_IniPadr("GCZ", 1, cNrSeqG, "GCZ_ALTGUI",, .F.) == "0"
	 EndIf
	 
	 If (lGuiaTiss).And.(!Empty(cNrGuia))
	  aAdd(aGuiaTiss,{nAtGcz, cCodCon,  cGcuTgTiss,cNrGuia,cNrSeqG})
	  lNrGTissAt := .T.
	 EndIf  
	EndIf

	If !Empty(cTpgCod) .And. (ValType(aColsGCZ) # "U")
  If(Empty(aColsGCZ[nAtGcz, nGczTATISS]))
   aColsGCZ[nAtGcz, nGczTATISS] := HS_IniPadr("GCU", 1, cTpgCod, "GCU_TATISS",,.F.)  
   aColsGCZ[nAtGcz, aScan(aHeaderGCZ, {|aVet| aVet[2] == "GCZ_DTATIS"})] := HS_IniPadR('G08', 1, aColsGCZ[nAtGcz, nGczTATISS], 'G08_DESCRI',,.F.)  
  EndIf
  If(Empty(aColsGCZ[nAtGcz, nGczTIPCON]))
   aColsGCZ[nAtGcz, nGczTIPCON] := HS_IniPadr("GCU", 1, cTpgCod, "GCU_TIPCON",,.F.)	  
   aColsGCZ[nAtGcz, aScan(aHeaderGCZ, {|aVet| aVet[2] == "GCZ_DTIPCO"})] := HS_IniPadR('G12', 1, aColsGCZ[nAtGcz, nGczTIPCON], 'G12_DESCRI',,.F.)
  EndIf 
	EndIf

 RestArea(aArea)
return(cNrGuia)   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_DelNrGT ³ Autor ³ Bruno S. P. Santos    ³ Data ³03.09.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que alimenta tabela de numeros reutilizaveis para as   ³±±
±±³          ³guias TISS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se numero TISS foi salvo na tabela de reutilizaveis    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Posição da guia deletada na MsNewGetDados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_VldM24                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_DelNrGT(nAt)
 Local aArea := GetArea()
 Local nPos  := 0
 Local lRet  := .F.

 If !HS_ExisDic({{"C","GCZ_ALTGUI"},{"C","GCU_TATISS"},{"C","GCU_TIPCON"}}, .F.)
  return(.T.)
 EndIf

 nPos  := aScan(aGuiaTiss,{|aVet| aVet[1] ==  nAt})
 
 If nPos > 0 
  Fs_AddGMZ(aGuiaTiss[nPos, 2],aGuiaTiss[nPos, 3], aGuiaTiss[nPos, 4]) 
	 
	 aDel(aGuiaTiss, nPos)
  aSize(aGuiaTiss, Len(aGuiaTiss) - 1)  
  lNrGTissAt := !(lRet := .T.) 
 Endif 

 RestArea(aArea)
Return(lRet)

Static Function FS_ANMEXT(cCodPac, cRegAte)
Local aArea 	:= GetArea()
Local cSql		:= ""
Local aHRN		:= {}
Local aCRN		:= {}
Local lPerg		:= .F.
Local lTela		:= .F.
Local aSize   	:= {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local nTdOk   	:= 0
Local cQryIn	:= "("  
Local nPosTP	:= 0
Local cGfuRes	:= ""
Local nCount	:= 0
  
Define  FONT oFont NAME "Arial,16," BOLD   
                 
// VERIFICA SE O PACIENTE TEM RN'S                 
cSql += "SELECT GFU_NOMPAC,GFU_CDANAM, GFU_RESERV FROM " + RetSqlName("GFU") + " GFU WHERE GFU_REGATE = '" + cRegAte + "' "
cSql += " AND GFU_RESERV <> '" + Space(TamSx3("GFU_RESERV")[1]) + "' AND D_E_L_E_T_ <> '*' AND GFU_FILIAL = '" + xFilial("GFU") + "' "

cSql := ChangeQuery(cSql)
 
TCQUERY cSQL NEW ALIAS "QRYGFU"

If !QRYGFU->(Eof())
	lPerg := .T.			
	While !Eof()
		cQryIn += "'" + QRYGFU->GFU_RESERV + "'"
		nCount ++
		DbSkip()
		If !Eof()
			cQryIn += ","
		Else             
			cQryIn += ")"
		EndIf
	End
	HS_BDados("GB2", @aHRN, @aCRN, , 1, cRegAte, "GB2->GB2_REGATE = '" + cRegAte + "' AND GB2->GB2_TPNASC IN " + cQryIn + "",,,,, )
	nPosTp := aScan(aHRN, {| aVet | aVet[2] == "GB2_TPNASC"})
EndIf

lTela := (nCount > 1)

QRYGFU->(DbGoTop())
cGfuRes := QRYGFU->GFU_RESERV  
QRYGFU->(DbCloseArea())

If !lPerg	
	HS_MNTMA7("GCY",cCodPac,2,2,)
Else 
	If MsgYesNo(STR0096,STR0003)  //"Deseja visualizar a Evolução do RN?""Atenção"
		If !lTela                               
			HS_MNTMA7("GCY",cCodPac,2,2,cGfuRes)
		Else
			aSize := MsAdvSize(.T.)
			aObjects := {}
			AAdd(aObjects, {100, 100, .T., .T.})	
			aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
			aPObjs := MsObjSize(aInfo, aObjects, .T.) 
			DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0095) From aSize[5]/15, aSize[6]/200 To aSize[6]/2, aSize[5]*0.65	PIXEL Of oMainWnd  //"Selecione o Recém Nascido para visualizar sua Anamnese"
				oGCZ := MsNewGetDados():New(aPObjs[1][1], aPObjs[1][2], aPObjs[1][3], aPObjs[1][4], 0,,,,,,,,,, oDlg,aHRN, aCRN) 
				oGCZ:oBrowse:align := CONTROL_ALIGN_ALLCLIENT  
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nTdOk := 1,IIf(Empty(oGCZ:aCols[oGCZ:nAt, nPosTp]),nTdOk := 0,), oDlg:End() }, {|| nTdOk := 0, oDlg:End()},, )  
			If nTdOk == 1                                                 
				HS_MNTMA7("GCY",cCodPac,2,2,oGCZ:aCols[oGCZ:nAt, nPosTp])
			EndIf
		EndIf
	Else
		HS_MNTMA7("GCY",cCodPac,2,2,)
	EndIf
EndIf
RestArea(aArea)
Return()

Static Function FS_VGRPLAB(cGruPro) 
 Local aArea := getArea()
Local cSql := ""  
Local lRet	:= .F.

If Empty(cGruPro)
	Return(.F.)
EndIf

cSql := " SELECT GAQ_CODLOC CODLOC "
cSql += "   FROM "+RetSqlName("GAQ")+" GAQ "
cSql += "   JOIN "+RetSqlName("GCS")+" GCS ON GCS_FILIAL = '"+xFilial("GCS")+"' AND GCS.D_E_L_E_T_ <> '*' AND GCS_CODLOC = GAQ_CODLOC  AND GCS_TIPLOC='G'"
cSql += "  WHERE GAQ_FILIAL = '"+xFilial("GAQ")+"' AND GAQ.D_E_L_E_T_ <> '*' AND GAQ_GRUPRO = '"+cGruPro+"' "           
cSql += "  UNION  "
cSql += " SELECT GNQ_CODLOC CODLOC "
cSql += "   FROM "+RetSqlName("GNQ")+" GNQ "
cSql += "   JOIN "+RetSqlName("GCS")+" GCS ON GCS_FILIAL = '"+xFilial("GCS")+"' AND GCS.D_E_L_E_T_ <> '*' AND GCS_CODLOC = GNQ_CODLOC AND GCS_TIPLOC='G' "
cSql += "  WHERE GNQ_FILIAL = '"+xFilial("GNQ")+"' AND GNQ.D_E_L_E_T_ <> '*' AND GNQ_GRUPRO = '"+cGruPro+"' "

TCQUERY cSql NEW ALIAS "QRYGRP"  

lRet := !QRYGRP->(Eof())    

QRYGRP->(DbCloseArea())

RestArea(aArea)
Return(lRet)
