#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM872CHI.CH"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funci�n   �GPEM872CHI� Autor � alfredo.medrano      � Data � 16/02/2015 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Genera Acumulados (Chile)                                   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM872CHI()                                                ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Preparar la informaci�n tanto del trabajador como de sus    ���
���          � acumulados anuales para la generaci�n de la Declaraci�n     ���
���          � Jurada Anual de Rentas.                                     ���
��������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.              ���
��������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS/FNC     �  Motivo da Alteracao              ���
��������������������������������������������������������������������������Ĵ��
���Alex Hdez   �25/11/15�PCREQ-7944    �Se paso a la v12 a partir del fuen-���
���            �        �              �te de v11 con la fecha 13/11/15    ���
��� Alex Hdez  �04/01/16�PCREQ-7944    �Se agrego funci�n GPE872RCWB para  ���
���            �        �              �borrar los datos en la tabla RCW.  ���
���            �        �              �Se modifico la funcion GPEM872RCV  ���
���            �        �              �al generar "cLlave" xFilial("RCV") ���
���            �        �              �por cFil. Se cambio la funcion GPEM���
���            �        �              �872RCW al generar "cLlave" xFilial ���
���            �        �              �("RCW") por cFil.                  ���
��� Alex Hdez  �14/12/15�PCREQ-7944    �Cambio funcion GPE872RCWB al genera���
���            �        �              �r "cLlave" xFilial("RCW") por cFil.���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function GPEM872CHI()
Local nOpca 	:= 0
Local aSays		:= {}
Local aButtons	:= {} //<== arrays locais de preferencia
Private cCadastro := OemToAnsi(STR0001) //"Generaci�n del Archivo de Declaracion Anual"

//��������������������������������������������������������������Ŀ
//� Variables utilizadas  parametros                             �
//� mv_par01 - �Sucursales?                                      �
//� mv_par02 - �Empleados?                                       �
//� mv_par03 - �Centralizar en la Sucursal ?                     �
//� mv_par04 - �A�o Base?                                        �
//� mv_par05 - �Respeta Ajustes Usuario?                         �
//����������������������������������������������������������������
If  Pergunte("GPEM872CHI",.T.)
	Processa( {|lEnd| GPEM872PRO(@lEnd)}, OemToAnsi(STR0007),OemToAnsi(STR0004), .T. ) //"Favor de Aguardar....." //"Incio de la generaci�n de acumulados para la Declaraci�n Anual"
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GPEM872PRO� Autor � Alfredo Medrano       � Data �17/02/2015���
�������������������������������������������������������������������������Ĵ��
���Descricao � Procesa informacion                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM872PRO(@ExpL1)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd = Boolean                                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPEM872CHI                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
static Function GPEM872PRO(lEnd)
Local	  aArea 	 := getArea()
Local 	  lRet 	 := .T.
Local	  cAliasGR	 := criatrab( nil, .f. )
Local	  cQuery 	 := ""
Local 	  cFil		 := ""
Local 	  cMat		 := ""
Local 	  aMesAcum	 := {}
Local 	  cAno		 := ""
Local 	  nTotal	 := 0
Private  cFils	 := ""
Private  cMats	 := ""
Private  cCentra	 := mv_par03
Private  nAno		 := mv_par04
Private  nRespAjustes := mv_par05
Private  nFolio := 0
Private cMatTmp := ""

lEnd := .T.
cAno := Alltrim(STR(nAno))
ProcRegua(1)
//convierte parametros tipo Range a expresion sql
//si esta separa por "-" agrega un BETWEEN,  si esta separado por ";" agrega un IN
MakeSqlExpr("GPEM872CHI")
	cFils		:= mv_par01
 	cMats		:= mv_par02

	//Se filtran los datos de las tablas RG7, SRA, SRV
	//Los renglones de conceptos diferentes RG7_PD pero del mismo RV_DIRF se suman
	cQuery := " SELECT RG7_FILIAL,RA_FILIAL,RG7_MAT,RA_MAT,RV_DIRF, "
	cQuery += " RA_CIC,RA_PRINOME,RA_PRISOBR,RA_SECSOBR,RA_ADMISSA,RA_DEMISSA, "
	cQuery += " SUM(RG7_ACUM01) MES1,SUM(RG7_ACUM02) MES2,SUM(RG7_ACUM03) MES3, "
	cQuery += " SUM(RG7_ACUM04) MES4,SUM(RG7_ACUM05) MES5, SUM(RG7_ACUM06) MES6, "
	cQuery += " SUM(RG7_ACUM07) MES7, SUM(RG7_ACUM08) MES8,SUM(RG7_ACUM09) MES9, "
	cQuery += " SUM(RG7_ACUM10) MES10,SUM(RG7_ACUM11) MES11, SUM(RG7_ACUM12) MES12 "
	cQuery += " FROM " + RetSqlName("RG7") + " RG7 INNER JOIN "
    cQuery +=   RetSqlName("SRA") + " SRA ON RG7.RG7_MAT = SRA.RA_MAT AND
    cQuery += " RG7.RG7_FILIAL=SRA.RA_FILIAL LEFT OUTER JOIN "
    cQuery +=	RetSqlName("SRV") + " SRV ON RG7.RG7_PD = SRV.RV_COD
    cQuery += " WHERE SRV.RV_DIRF NOT IN (' ', 'N') AND RG7.RG7_CODCRI='01' "
   If	!Empty( cAno )
		cQuery += " AND RG7_ANOINI = '" + cAno +" '"
	EndIf
   If	!Empty( cFils )
		cQuery += " AND " + cFils
	EndIf
	If	!Empty( cMats )
		cQuery += " AND " + cMats
	EndIf
	cQuery += " AND SRV.RV_FILIAL	=  '" + XFILIAL('SRV') + "' "
	cQuery += " AND RG7.D_E_L_E_T_ = ' ' "
	cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
	cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY  RG7.RG7_FILIAL, SRA.RA_FILIAL, RG7.RG7_MAT, SRA.RA_MAT, SRV.RV_DIRF, "
	cQuery += " SRA.RA_CIC,SRA.RA_PRINOME,SRA.RA_PRISOBR, SRA.RA_SECSOBR, SRA.RA_ADMISSA, SRA.RA_DEMISSA "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasGR,.T.,.T.)

	TCSetField(cAliasGR,"RA_ADMISSA","D",8,0) // Formato de fecha
	TCSetField(cAliasGR,"RA_DEMISSA","D",8,0) // Formato de fecha

	Count to nTotal
	If nTotal <= 0
		Msginfo(OemToAnsi(STR0018) )//"No existe informaci�n con esos par�metros"
		Return Nil
	EndIf

	ProcRegua(nTotal)
	(cAliasGR)->(dbgotop())//primer registro de tabla
	While  (cAliasGR)->(!EOF())

	IncProc(OemToAnsi(STR0017) + ( cAliasGR )->RA_MAT  ) //"Procesando Empleado : "
		If cFil != ( cAliasGR )->RA_FILIAL .or. cMat != ( cAliasGR )->RA_MAT
			cCentra := If(Empty(cCentra), (cAliasGR)->RA_FILIAL, cCentra)

			IF cFil != ( cAliasGR )->RA_FILIAL
				nFolio := 0
			EndIf

			GPEM872RCV(	( cAliasGR )->RA_FILIAL, ( cAliasGR )->RA_MAT, ( cAliasGR )->RA_CIC, nAno,;
							( cAliasGR )->RA_ADMISSA, ( cAliasGR )->RA_DEMISSA, ( cAliasGR )->RA_PRINOME, '',;
							( cAliasGR )->RA_PRISOBR, ( cAliasGR )->RA_SECSOBR, cCentra )
		EndIf

		AADD(aMesAcum,{	( cAliasGR )->MES1,( cAliasGR )->MES2,( cAliasGR )->MES3,( cAliasGR )->MES4,( cAliasGR )->MES5,;
							( cAliasGR )->MES6,( cAliasGR )->MES7,( cAliasGR )->MES8,( cAliasGR )->MES9,( cAliasGR )->MES10,;
							( cAliasGR )->MES11,( cAliasGR )->MES12})
		

		GPEM872RCW(	( cAliasGR )->RA_FILIAL, ( cAliasGR )->RA_MAT, ( cAliasGR )->RA_CIC, nAno,;
						( cAliasGR )->RA_ADMISSA, ( cAliasGR )->RA_DEMISSA, ( cAliasGR )->RV_DIRF, aMesAcum )

		cFil := ( cAliasGR )->RA_FILIAL
		cMat := ( cAliasGR )->RA_MAT

		aMesAcum :={}
	( cAliasGR )-> (dbskip())

	EndDo

	Msginfo( OemToAnsi(STR0006))//"Proceso Generado con �xito."
	( cAliasGR )->(dbCloseArea())
	restArea(aArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GPEM872RCV� Autor � Alfredo Medrano       � Data �18/02/2015���
�������������������������������������������������������������������������Ĵ��
���Descricao � Agrega Registros en la Tabla RCV Decla. Jurada Encabezado  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM872RCV(ExpC1,ExpC2,ExpC3,ExpN4,ExpD5,ExpD6,ExpC7,ExpC8 ���
���          � ExpC9,ExpC10)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Filial,  ExpC1 = Matricula,  ExpC3 = RUT,          ���
���          � ExpN4 = Anio,    ExpD5 = Fch. Admis, ExpD6 = Fch. Dems,    ���
���          � ExpC7 = Prim.Nom ExpC8 = Sec.Nom     ExpC9 = Prim.Sobr.,   ���
���          � ExpC10= Sec.Sobr                                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPEM872PRO                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GPEM872RCV (cFil, cMat, cCIC, nAnio, dAdmss, dDemss, cPriNom, cSecnom, cPrisob, cSecsob, cCentra )
Local nAux01    := 0
Local cRutDecla := ""
Local cNomDecla := ""
Local cRutReLeg := ""
Local cNomReLeg := ""
Local cMailDecl := ""
Local cAnio	  := Alltrim(STR(nAno))
Local cEmpresa  := ""
Local cLlave    := ""
Local cMesIni   := If( Year(dAdmss) >= nAnio, StrZero(Month(dAdmss),2), "01" )
Local cMesFin   := If( Year(dDemss) == nAnio, StrZero(Month(dDemss),2), "12" )
Local lSalir    := .F.

    DbSelectArea("SRA")
    DbSetOrder(1) // RA_FILIAL + RA_MAT
    If dbSeek(xFilial("SRA") + cMat)
        cEmpresa := SRA->RA_EMPRESA
    EndIf
    SRA->( dbCloseArea() )

    nAux01 := fPosTab("S013", cEmpresa, "=", 4)

    dbSelectArea("SM0")
    SM0->(dbSetOrder(1))

    If Empty(cCentra)
        cCentra := cFil
    EndIf

    If ( SM0->(dbSeek( SM0->M0_CODIGO + cCentra )))
        cRutDecla := SM0->M0_CGC	 // Rut Declarante
        cNomDecla := SM0->M0_NOMECOMP  //Nom. Declarante
    EndIf

    cRutReLeg := If(nAux01 > 0, fTabela("S013", nAux01, 6), " ") //Rut Representante Legal
    cNomReLeg := If(nAux01 > 0, fTabela("S013", nAux01, 5), " ") //Nom. Representante Legal
    cMailDecl := If(nAux01 > 0, fTabela("S013", nAux01, 7), " ") //Email Declarante
    nFolio++

/*Agrega registro a la tabla RCV encabezado Decla. Jurada */
// Si existe un registro en esta BD
	dbSelectArea("RCV")
	dbSetOrder(1) // 8RCV_FILIAL+6RCV_MAT+9RCV_RFC+4RCV_ANO+2RCV_MESINI+2RCV_MESFIN=31
	cLlave := cFil+cMat+cCIC+cAnio+cMesIni+cMesFin

    If dbSeek(cLlave) // si lo encuentra lo borra
        If (nRespAjustes == 2 .And. RCV->RCV_STATUS == "U") // respetar ajustes por el usuario
            lSalir := .T.
        Else // borrado
            While RCV->(!eof()) .and. RCV->RCV_FILIAL+RCV->RCV_MAT+RCV->RCV_RFC+RCV->RCV_ANO+RCV->RCV_MESINI+RCV->RCV_MESFIN == cLlave
            //Elimina los registros de la tabla "Declaracion Jurada Detalle"
                RecLock("RCV",.F.,.T.)
                RCV->(dbDelete())
                MsUnlock()
                RCV->(dbSkip())
                IncProc(OemToAnsi(STR0014))//"Limpiando Tabla RCV..."
            EndDo
        EndIf
    EndIf

    If (!lSalir)
        RecLock("RCV", .T.) // inserta un registro nuevo
	        RCV->RCV_FILIAL 	:= cFil
	        RCV->RCV_MAT 	:= cMat
	        RCV->RCV_RFC 	:= cCIC
	        RCV->RCV_ANO 	:= cAnio
	        RCV->RCV_MESINI 	:= cMesIni
	        RCV->RCV_MESFIN 	:= cMesFin
	        RCV->RCV_PRINOM	:= cPriNom
	        RCV->RCV_SEGNOM	:= cSecnom
	        RCV->RCV_PRISOB	:= cPrisob
	        RCV->RCV_SEGSOB	:= cSecsob
	        RCV->RCV_FILFON	:= cCentra
	        RCV->RCV_RFCFON	:= cRutDecla
	        RCV->RCV_NOMFON 	:= cNomDecla
	        RCV->RCV_RFCREP	:= cRutReLeg
	        RCV->RCV_EMAIL	:= cMailDecl
	        RCV->RCV_NOMREP	:= cNomReLeg
	        RCV->RCV_STATUS	:= "S"
	        RCV->RCV_FOLIO	:= nFolio
        RCV->(MsUnlock())

        IncProc(OemToAnsi(STR0012))//"Agregando Registros a Tabla RCV..."
	EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GPEM872RCW� Autor � Alfredo Medrano       � Data �18/02/2015���
�������������������������������������������������������������������������Ĵ��
���Descricao � Agrega Registros en la Tabla RCW Decla. Jurada Detalle.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM872RCW(ExpC1,ExpC2,ExpC3,ExpN4,ExpD5,ExpD6,ExpC7,ExpA8 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Filial,  ExpC1 = Matricula,  ExpC3 = RUT,          ���
���          � ExpN4 = Anio,    ExpD5 = Fch. Admis, ExpD6 = Fch. Dems,    ���
���          � ExpC7 = Dirf.    ExpA8 = Valor de los Meses                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPEM872PRO                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GPEM872RCW(cFil, cMat, cCIC, nAnio, dAdmss, dDemss, cDirf, aMesAcum )
Local nNum		:= 12
Local nX		:= 0
Local cAnio	:=  Alltrim(STR(nAno))
Local cMesIni := If( Year(dAdmss) >= nAnio, StrZero(Month(dAdmss),2), "01" )
Local cMesFin := If( Year(dDemss) == nAnio, StrZero(Month(dDemss),2), "12" )

IF cMatTmp <> cMat //Borra los datos de la RCW 
	GPE872RCWB(cFil, cMat, cCIC, nAnio, dAdmss, dDemss )
	cMatTmp := cMat
EndIf

For nX := 1  To nNum
/*Agrega registro a la tabla RCW detalle Decla. Jurada */
    dbSelectArea("RCW")
    dbSetOrder(1) // RCW_FILIAL+RCW_MAT+RCW_RFC+RCW_ANO+RCW_MESINI+RCW_MESFIN+RCW_MES+RCW_TIPORE 
    cLlave := cFil+cMat+cCIC+cAnio+cMesIni+cMesFin+strzero(nX,2)+cDirf
    If !dbSeek(cLlave)
       	RecLock("RCW", .T.) // inserta un registro nuevo
			RCW->RCW_FILIAL 	:= cFil
			RCW->RCW_MAT 	:= cMat
			RCW->RCW_RFC 	:= cCIC
			RCW->RCW_ANO 	:= cAnio
			RCW->RCW_MESINI 	:= cMesIni
			RCW->RCW_MESFIN	:= cMesFin
			RCW->RCW_TIPORE	:= cDirf
			RCW->RCW_MES		:= strzero(nX,2)
			RCW->RCW_VALOR	:= aMesAcum[1][nX]
			RCW->RCW_STATUS	:= "S"
			RCW->(MsUnlock())
			IncProc(OemToAnsi(STR0016))		//"Agregando Registros a Tabla RCW..."   
		  	
	ENDIF
Next

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GPE872RCWB� Autor � Alex Hdez             � Data �04/12/2015���
�������������������������������������������������������������������������Ĵ��
���Descricao � Borra los datos del empleado de la Tabla RCW.              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPE872RCWB(ExpC1,ExpC2,ExpC3,ExpN4,ExpD5,ExpD6)            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Filial,  ExpC1 = Matricula,  ExpC3 = RUT,          ���
���          � ExpN4 = Anio,    ExpD5 = Fch. Admis, ExpD6 = Fch. Dems     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPEM872CHI                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GPE872RCWB(cFil, cMat, cCIC, nAnio, dAdmss, dDemss)
Local nNum		:= 12
Local nX		:= 0
Local cAnio	:=  Alltrim(STR(nAno))
Local cMesIni := If( Year(dAdmss) >= nAnio, StrZero(Month(dAdmss),2), "01" )
Local cMesFin := If( Year(dDemss) == nAnio, StrZero(Month(dDemss),2), "12" )

For nX := 1  To nNum
/*Agrega registro a la tabla RCW detalle Decla. Jurada */
    dbSelectArea("RCW")
    dbSetOrder(1) // RCW_FILIAL+RCW_MAT+RCW_RFC+RCW_ANO+RCW_MESINI+RCW_MESFIN+RCW_MES+RCW_TIPORE 
    cLlave := cFil+cMat+cCIC+cAnio+cMesIni+cMesFin+strzero(nX,2)

    If dbSeek(cLlave) // si lo encuentra lo borra
            While RCW->(!eof()) .and. RCW->RCW_FILIAL+RCW->RCW_MAT+RCW->RCW_RFC+RCW->RCW_ANO+RCW->RCW_MESINI+RCW->RCW_MESFIN+RCW->RCW_MES == cLlave 
                //Elimina los registros de la tabla "Declaracion Jurada Detalle"
                If !(nRespAjustes == 2 .And. RCW->RCW_STATUS == "U") .OR. nRespAjustes == 1 // respetar ajustes por el usuario
	                RecLock("RCW",.F.,.T.)
	                RCW->(dbDelete())
	                MsUnlock()
	                IncProc(OemToAnsi(STR0015))     //"Limpiando Tabla RCW..."
	             Endif        
                RCW->(dbSkip())                
            EndDo
    EndIf

Next

Return
