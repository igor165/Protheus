#INCLUDE "PROTHEUS.CH" 
#INCLUDE "GPEA015.CH" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPEA015   �Autor  �Luis Samaniego      �Fecha �  15/12/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �Provisi�n de vacaciones                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GPEA015                                                    ���
�������������������������������������������������������������������������͹��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������͹��
���Programador � Data   �Llamado �  Motivo da Alteracao                   ���
�������������������������������������������������������������������������͹��
���Dora Vega   �04/04/17�MMI-167 � Merge de replica del llamado TRWNBS.   ���
���            �        �        � Se agrega el fuente para la v12.1.14,  ���
���            �        �        � el cual actualiza la tabla SRA en los  ���
���            �        �        � campos RA_DVACANT, RA_DVACACT; Conforme���
���            �        �        � a los parametros informados en el grupo���
���            �        �        � de preguntas GPEA015. (ARG)            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GpeProVac �Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Obtiene informacion de la tabla SRA, obteniendo la filial  ���
���          � y matriz del empleado                                      ���
�������������������������������������������������������������������������͹��
���Uso       � GPEA015                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	
	//�����������������������������������������������������������Ŀ
	//� MV_PAR01 -> Proceso                                       �
	//� MV_PAR02 -> De Matricula                                  �
	//� MV_PAR03 -> A Matricula                                   �
	//� mv_par04 -> De Sucursal                                   �
	//� MV_PAR05 -> A Sucursal                                    �
	//� MV_PAR06 -> De departamento                               �
	//� MV_PAR07 -> A Departamento                                �
	//�������������������������������������������������������������
	
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GpemSRF   �Autor  �Luis Samaniego      �Fecha �  15/12/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Obtiene informaci�n de la tabla SRF                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GpeProVac                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPEDelArea�Autor  �Luis Samaniego      �Fecha �  15/12/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Elimina tablas temporales                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GPEDelArea                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GPEDelArea(cArchTmp)
	(cArchTmp)->(dbCloseArea())
Return