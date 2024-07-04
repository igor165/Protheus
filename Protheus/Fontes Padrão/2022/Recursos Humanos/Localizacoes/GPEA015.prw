#INCLUDE "PROTHEUS.CH" 
#INCLUDE "GPEA015.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA015   ºAutor  ³Luis Samaniego      ºFecha ³  15/12/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Provisión de vacaciones                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA015                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º Data   ºLlamado º  Motivo da Alteracao                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÅÍÍÍÍÍÍÍÍÅÍÍÍÍÍÍÍÍÅÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDora Vega   º04/04/17ºMMI-167 º Merge de replica del llamado TRWNBS.   º±±
±±º            º        º        º Se agrega el fuente para la v12.1.14,  º±±
±±º            º        º        º el cual actualiza la tabla SRA en los  º±±
±±º            º        º        º campos RA_DVACANT, RA_DVACACT; Conformeº±±
±±º            º        º        º a los parametros informados en el grupoº±±
±±º            º        º        º de preguntas GPEA015. (ARG)            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPEA015()
	Local cPerg    := "GPEA015"
	Local nOpcA    := 0
	Local aSays    := {}
	Local aButtons := {}

	Pergunte( cPerg, .F. )
	aAdd(aSays,OemToAnsi( STR0001 ) ) //Ley de contrato de trabajo - provision vacaciones
	aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{ |o| nOpcA := 1, o:oWnd:End() } } )
	aAdd(aButtons, { 2,.T.,{ |o| nOpcA := 2, o:oWnd:End() } } )             
	FormBatch( oemtoansi(STR0002), aSays , aButtons ) //Provision de vacaciones
	
	If nOpcA == 1 
		Processa({ || GpeProVac() })
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GpeProVac ºAutor  ³Luis Samaniego      ºFecha ³  20/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene informacion de la tabla SRA, obteniendo la filial  º±±
±±º          ³ y matriz del empleado                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA015                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GpeProVac()
	Local cQrySRA    := ""
	Local cTmpSRA    := CriaTrab(Nil, .F.)
	
	Private nDPerAnt := 0
	Private nDPerAct := 0
	Private cProc    := MV_PAR01
	Private cDeMat   := MV_PAR02
	Private cAMat    := MV_PAR03
	Private cDeSuc   := MV_PAR04
	Private cASuc    := MV_PAR05
	Private cDeDepto := MV_PAR06
	Private cADepto  := MV_PAR07
	Private nYearAct := Year(Date())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MV_PAR01 -> Proceso                                       ³
	//³ MV_PAR02 -> De Matricula                                  ³
	//³ MV_PAR03 -> A Matricula                                   ³
	//³ mv_par04 -> De Sucursal                                   ³
	//³ MV_PAR05 -> A Sucursal                                    ³
	//³ MV_PAR06 -> De departamento                               ³
	//³ MV_PAR07 -> A Departamento                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	DbSelectArea("SRA")
	SRA->(DBSetOrder(1)) //RA_FILIAL+RA_MAT
		
	cQrySRA := " SELECT RA_FILIAL, RA_MAT, RA_PROCES, RA_DEPTO, RA_SITFOLH "
	cQrySRA += " FROM " + RetSQLName("SRA")
	cQrySRA += " WHERE (RA_PROCES = '" + cProc + "') AND "
	cQrySRA += " (RA_MAT >= '" + cDeMat + "' AND RA_MAT <= '" + cAMat + "') AND "
	cQrySRA += " (RA_FILIAL >= '" + cDeSuc + "' AND RA_FILIAL <= '" + cASuc + "') AND "
	cQrySRA += " (RA_DEPTO >= '" + cDeDepto + "' AND RA_DEPTO <= '" + cADepto + "') AND "
	cQrySRA += " RA_SITFOLH <> 'D' AND"
	cQrySRA += " D_E_L_E_T_ = ''"
	cQrySRA += " ORDER BY RA_FILIAL, RA_MAT, RA_DEPTO ASC"
	
	cQrySRA := ChangeQuery(cQrySRA)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySRA),cTmpSRA,.F.,.T.)  
	(cTmpSRA)->(dbGoTop())
	
	ProcRegua((cTmpSRA)->(RecCount()))
	While (cTmpSRA)->(!EOF())
		GpeSRF((cTmpSRA)->RA_FILIAL, (cTmpSRA)->RA_MAT)
		(cTmpSRA)->(dbSkip())
	EndDo
	
	GPEDelArea(cTmpSRA)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GpemSRF   ºAutor  ³Luis Samaniego      ºFecha ³  15/12/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene información de la tabla SRF                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GpeProVac                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GpeSRF(cFilEmp, cMatEmp)
	Local cQrySRF  := ""
	Local cTmpSRF  := CriaTrab(Nil, .F.)

	cQrySRF := " SELECT RF_FILIAL, RF_MAT, RF_DATAFIM, RF_DIASDIR, RF_DFERANT, RF_STATUS "
	cQrySRF += " FROM " + RetSQLName("SRF")
	cQrySRF += " WHERE (RF_FILIAL = '" + cFilEmp + "') AND "
	cQrySRF += " (RF_MAT = '" + cMatEmp + "') AND "
	cQrySRF += " (RF_STATUS = '1') AND"
	cQrySRF += " D_E_L_E_T_ = ''"
	cQrySRF += " ORDER BY RF_DATAFIM ASC"
	
	cQrySRF := ChangeQuery(cQrySRF)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySRF),cTmpSRF,.F.,.T.)  
	
	//TcSetField(Alias - Campo - Tipo - Tamanio - Decimal) 
	TcSetField((cTmpSRF), "RF_DATAFIM", TamSx3("RF_DATAFIM")[3], TamSx3("RF_DATAFIM")[1], TamSx3("RF_DATAFIM")[2])   
	(cTmpSRF)->(dbGoTop())
	
	While (cTmpSRF)->(!EOF())
		If Year((cTmpSRF)->RF_DATAFIM) == nYearAct
			nDPerAct += (cTmpSRF)->RF_DIASDIR - (cTmpSRF)->RF_DFERANT
		Else
			nDPerAnt += (cTmpSRF)->RF_DIASDIR - (cTmpSRF)->RF_DFERANT
		EndIf
		(cTmpSRF)->(dbSkip())
	EndDo
	
	If SRA->(MsSeek(cFilEmp + cMatEmp))
		Begin Transaction
			RecLock("SRA",.F.)
				SRA->RA_DVACANT := nDPerAnt
				SRA->RA_DVACACT := nDPerAct
			MsUnLock()
		End Transaction
	EndIf
	
	nDPerAnt := 0
	nDPerAct := 0
	
	GPEDelArea(cTmpSRF)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEDelAreaºAutor  ³Luis Samaniego      ºFecha ³  15/12/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Elimina tablas temporales                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEDelArea                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPEDelArea(cArchTmp)
	(cArchTmp)->(dbCloseArea())
Return