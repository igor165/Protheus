#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER908.CH"
/*/
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPER908  � Autor � Luis Trombini     	� Data � 20/10/2010	         ���
������������������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Conferencia  - RDEP 						             ���
������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER908()                                                	         ���
������������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                       ���
������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico - Equador                                              	     ���
������������������������������������������������������������������������������������Ĵ��
���             ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                    ���
������������������������������������������������������������������������������������Ĵ��
���Programador � Data   � Chamado   �  Motivo da Alteracao 		                     ���
���Kelly S.    �27/10/11� TEIHIO    �Ajuste na impressao do importo retido. 		 ���
���Emerson Camp�23/02/12�TEIHIO     �Ajuste na montagem da query para padronizar com ���
���            �        �           �o DB2 e ajuste de SX1                           ���
���            �        �           �                                                ���
���Jonathan Glz�07/05/15� PCREQ-4256�Se elimina funcion AjustaSx1 que realiza modifi-���
���            �        �           �cacion al diccionario de datos(SX1) por motivo  ���
���            �        �           �de ajuste nueva estructura de SXs para V12      ���
�������������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������������
/*/
Function GPER908()
	//��������������������������������������������������������������Ŀ
	//� Define Variaveis Locais (Basicas)                            �
	//����������������������������������������������������������������
	Private cAno    		:= ""
	private cFiltro		:= ""
	Private aReturn  := {STR0011, 1,STR0012, 1, 1, 1, "",1 }	//"Zebrado"###"Administra��o"
	Private cDesc1 := STR0003		//"Emissao Confer�ncia Formulario 107."
	Private cDesc2 := STR0004		//"Ser� impresso de acordo com os parametros solicitados pelo"
	Private cDesc3 := STR0005		//"usuario."
	Private aOrd   	:= {STR0006,STR0007,STR0008,STR0009,STR0010} //"Matricula"###"C.Custo"###"Nome"###"Chapa"###"C.Custo + Nome"
	Private oPrint
	Private li     		:= _PROW()
	Private cString	:= ""
	Private wnrel
	Private cPerg    	:= "GPR908"
	Private Titulo 		:= STR0003		//"SRI - Confer�ncia FORMULARIO 107"
	Private cTamanho 	:= "P"
	Private cDtEntrega	:= CTOD(" /  /  ")

	cAno := AllTrim(Transform(MV_PAR03,"9999"))
	cDtEntrega  := MV_PAR04
	cString	:= ""
	wnrel	:= "GPER908"            //Nome Default do relatorio em Disco
	wnrel	:= SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,cTamanho)

	If nLastKey == 27
		Return
	EndIf

	SetDefault(aReturn,cString,,,cTamanho,1)

	If nLastKey == 27
		Return
	EndIf

	Pergunte("GPER908",.F.)

	cAno := AllTrim(Transform(MV_PAR03,"9999"))

	cDtEntrega  := MV_PAR04 // StrZero(Year(mv_par04),4) + StrZero(Month(mv_par04),2) + StrZero(Day(mv_par04),2)
	cAliasRH6 := "RH6"
	#IFDEF TOP



		//--Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
		MakeSqlExpr("GPR908")

		//-- Adiciona no filtro o parametro tipo Range
		cFiltro := "%"

		cFiltro += "RH6.RH6_ANORET = '"+cAno+"'"
		//-- Filial
		If !Empty(MV_PAR01)
			cFiltro += " AND " + MV_PAR01
		EndIf

		//-- MATRICULA
		If !Empty(MV_PAR02)
			cFiltro += " AND " + MV_PAR02
		EndIf
        cFiltro += "%"

    	//��������������������������������������������������������������Ŀ
		//� Consiste o filtro incluido pelo usuario -bt.personalizar     �
		//����������������������������������������������������������������

		cOrdem := "%RH6.RH6_FILIAL, RH6.RH6_MAT%"

        RH6->(dbCloseArea())
		//dbSelectArea(cAliasSRA)
		BeginSql alias cAliasRH6
    	SELECT RH6.*
  			FROM %table:RH6% RH6
			WHERE  RH6.%notDel%  AND
			   	   %exp:cFiltro%
			ORDER BY %exp:cOrdem%
		EndSql

	#Endif

 	Pag := 0
    LI := 65
	DbSelectArea( cAliasRH6 )
	dbgotop()
	If !Eof()
		While RH6->( !Eof() )
//			If RH6->RH6_ANORET == cAno
				MsAguarde( fDetalhe(), OemToAnsi(STR0013))
//			EndIf
			RH6->( dbSkip() )
		EndDo
	EndIf

	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel)
	EndIf
    (cAliasRH6)->(dbclosearea())
	MS_FLUSH()


Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fDetalhe  � Autor � Luis Trombini         � Data � 20/10/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � IMPRESSAO Cabecalho Form Continuo SRI                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCabec()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fDetalhe()			// Cabecalho do DREP
	Local cExer			:= ""
	Local cExerCom		:= ""
	cDATA := DTOS(cDtEntrega)
	cExer := RH6->RH6_ANORET
	cExerCom := SubStr(cDATA,1,1)  + SubStr(cDATA,2,1) + SubStr(cDATA,3,1) + SubStr(cDATA,4,1) + "/"
	cExerCom +=	SubStr(cDATA,5,1) + SubStr(cDATA,6,1) + "/"
	cExerCom +=	SubStr(cDATA,7,1) + SubStr(cDATA,8,1)

	// Cabecalho
	If  Li > 64
	    LI := 1
	    Pag += 1
 		@ Li,000 PSAY __PrtThinLine()
  		Li := Li + 1
		@ Li,30  PSAY STR0014
		@ Li,100 Psay "Fecha Emis�on : "
 		@ Li,117 Psay Date()
		Li := Li + 1
		@ Li,030 PSAY STR0003
		@ Li,100 Psay "Pagina        : "
		@ Li,123 Psay strzero(Pag,4)
		Li := Li + 1
		@ Li,000 PSAY __PrtThinLine()
		Li:= 5
 	Endif

//	@ PROW(),PCOL() PSAY "INFORME DE CONFERENCIA DEL FORMULARIO 107 - DREP"

	@ LI,05 PSAY "EJERCICIO FISCAL : "+ SubStr(cExer,1,1) + " " + SubStr(cExer,2,1) + " " + SubStr(cExer,3,1) + " " + SubStr(cExer,4,1)
	@ LI,54 PSAY "FECHA DE ENTREGA : " + cExerCom
	LI += 2
	@ LI,05 PSAY "R.U.C.: " + SM0->M0_CGC
	@ LI,54 PSAY "RAZ�N SOCIAL : " + SM0->M0_NOME
	LI += 1
	@ LI,05 PSAY "LEGAJO: " + RH6->RH6_MAT
	@ LI,54 PSAY "APELIDOS Y NOMBRES COMPLETOS: " + RH6->RH6_NOME
	LI += 1
	@ LI,05 PSAY "DIRECCION: "+RH6->RH6_DIRCAL
    @ LI,54 PSAY "NR. DIRECCION: " +RH6->RH6_DIRNUM
    Li += 1
    @ LI,05 PSAY "COD. PROVINCIA: "+RH6->RH6_CODEST
    @ LI,54 PSAY "COD. CIUDAD: "+RH6->RH6_CODMUN
    LI += 1
	@ LI,05 PSAY "TELEFONO: " + RH6->RH6_NRTELE
	@ LI,54 PSAY "CEDULA O PASAPORTE: " + RH6->RH6_IDRET
	LI += 1
	@ LI,05 PSAY "SISTEMA SUELDO: " + RH6->RH6_SISSAL
	@ LI,54 PSAY "NR. MESES TRABAJADOS: " + STRZERO(RH6->RH6_NUMMES,2)
    LI += 5
    @ Li,000 PSAY __PrtThinLine()
	LI += 1
 	@ LI,05 PSAY "LIQUIDAC�ON DEL IMPUESTO"
	LI += 1
	@ Li,000 PSAY __PrtThinLine()
	LI += 1
	@ Li,05 PSAY STR0015
	LI += 1
	@ Li,000 PSAY __PrtThinLine()
	LI += 1
	@ Li,05 PSAY "SUELDOS Y SALARIOS"
	@ LI,100 PSAY "301   (+)"
	@ LI,115 PSAY Transform(RH6->RH6_SALAR,"@E 9,999,999.99")		//SUELDOS Y SALARIOS
	LI += 1
	@ Li,05 PSAY "SOBRESUELDOS, COMISIONES, BONOS Y OTRAS REMUNERACIONES GRAVADAS"
  	@ LI,100 PSAY "303   (+)"
	@ LI,115 PSAY Transform(RH6->RH6_COMISS,"@E 9,999,999.99") 		//SOBRESUELDOS, COMISIONES, BONOS Y OTRAS REMUNERACIONES GRAVADAS
	LI += 1
	@ Li,05 PSAY "D�CIMO TERCER SUELDO (Informativo)"
  	@ LI,100 PSAY "305   ( )"
	@ LI,115 PSAY Transform(RH6->RH6_D13SAL,"@E 9,999,999.99")		//D�CIMO TERCER SUELDO (Informativo)
	LI += 1
	@ Li,05 PSAY "D�CIMO CUARTO SUELDO (Informativo)"
  	@ LI,100 PSAY "307   ( )"
	@ LI,115 PSAY Transform(RH6->RH6_D14SAL,"@E 9,999,999.99")		//D�CIMO CUARTO SUELDO (Informativo)
	LI += 1
	@ Li,05 PSAY "FONDO DE RESERVA (Informativo)"
  	@ LI,100 PSAY "309   ( )"
	@ LI,115 PSAY Transform(RH6->RH6_FONDO,"@E 9,999,999.99")		//FONDO DE RESERVA (Informativo)
	LI += 1
	@ Li,05 PSAY "PARTICIPACI�N UTILIDADES"
  	@ LI,100 PSAY "311   (+)"
	@ LI,115 PSAY Transform(RH6->RH6_PARUTI,"@E 9,999,999.99")		//PARTICIPACI�N UTILIDADES
	LI += 1
	@ Li,05 PSAY "DESAHUCIO Y OTRAS REMUNERACIONES QUE NO CONSTITUYEN RENTA GRAVADA (Informativo)"
  	@ LI,100 PSAY "313   ( )"
	@ LI,115 PSAY Transform(RH6->RH6_VRESCI,"@E 9,999,999.99")		//DESAHUCIO Y OTRAS REMUNERACIONES QUE NO CONSTITUYEN RENTA GRAVADA (Informativo)
	LI += 1
	@ Li,05 PSAY "APORTE PERSONAL IESS (�nicamente pagado por el empleado)"
  	@ LI,100 PSAY "315   (-)"
	@ LI,115 PSAY Transform(RH6->RH6_APIESS,"@E 9,999,999.99")		//(-) APORTE PERSONAL IESS (�nicamente pagado por el empleado)
	LI += 1
	@ Li,05 PSAY "DEDUCCI�N GASTOS PERSONALES - VIVIENDA"
  	@ LI,100 PSAY "317   (-)"
	@ LI,115 PSAY Transform(RH6->RH6_DEDVIV,"@E 9,999,999.99")		//(-) DEDUCCI�N GASTOS PERSONALES - VIVIENDA
	LI += 1
	@ Li,05 PSAY "DEDUCCI�N GASTOS PERSONALES - SALUD"
  	@ LI,100 PSAY "319   (-)"
	@ LI,115 PSAY Transform(RH6->RH6_DEDSAL,"@E 9,999,999.99")		//(-) DEDUCCI�N GASTOS PERSONALES - SALUD
	LI += 1
	@ Li,05 PSAY "DEDUCCI�N GASTOS PERSONALES - EDUCACI�N"
  	@ LI,100 PSAY "321   (-)"
	@ LI,115 PSAY Transform(RH6->RH6_DEDEDU,"@E 9,999,999.99")		//(-) DEDUCCI�N GASTOS PERSONALES - EDUCACI�N
	LI += 1
	@ Li,05 PSAY "DEDUCCI�N GASTOS PERSONALES - ALIMENTACI�N"
  	@ LI,100 PSAY "323   (-)"
	@ LI,115 PSAY Transform(RH6->RH6_DEDALI,"@E 9,999,999.99")		//(-) DEDUCCI�N GASTOS PERSONALES - ALIMENTACI�N
	LI += 1
	@ Li,05 PSAY "DEDUCCI�N GASTOS PERSONALES - VESTIMENTA"
  	@ LI,100 PSAY "325   (-)"
	@ LI,115 PSAY Transform(RH6->RH6_DEDVES,"@E 9,999,999.99")		//(-) DEDUCCI�N GASTOS PERSONALES - VESTIMENTA
	LI += 1
	@ Li,05 PSAY "REBAJA POR DISCAPACIDAD"
  	@ LI,100 PSAY "327   (-)"
	@ LI,115 PSAY Transform(RH6->RH6_DESCAP,"@E 9,999,999.99")		//(-) REBAJA POR DISCAPACIDAD
	LI += 1
	@ Li,05 PSAY "REBAJA POR TERCERA EDAD"
  	@ LI,100 PSAY "329   (-)"
	@ LI,115 PSAY Transform(RH6->RH6_TERIDA,"@E 9,999,999.99")		//(-) REBAJA POR TERCERA EDAD
	LI += 1
	@ Li,05 PSAY "IMPUESTO A LA RENTA ASUMIDO POR ESTE EMPLEADOR"
  	@ LI,100 PSAY "331   (+)"
	@ LI,115 PSAY Transform(RH6->RH6_INRETE,"@E 9,999,999.99")		//IMPUESTO A LA RENTA ASUMIDO POR ESTE EMPLEADOR
	LI +=1
	@ Li,05 PSAY "SUBTOTAL ESTE EMPLEADOR"
  	@ LI,100 PSAY "351   (=)"
	@ LI,115 PSAY Transform(RH6->RH6_SUBTOT,"@E 9,999,999.99")		//SUBTOTAL ESTE EMPLEADOR
 														//(301+303+311-315-317-319-321-323-325-327-329+331)
	LI += 1
	@ Li,05 PSAY "N�MERO DE MESES TRABAJADOS CON ESTE EMPLEADOR"
  	@ LI,100 PSAY "353   (+)"
	@ LI,115 PSAY Transform(RH6->RH6_NUMMES,"@E 999")				//N�MERO DE MESES TRABAJADOS CON ESTE EMPLEADOR
	LI += 1
	@ Li,05 PSAY "INGRESOS GRAVADOS GENERADOS CON OTROS EMPLEADORES"
  	@ LI,100 PSAY "401   (+)"
	@ LI,115 PSAY Transform(RH6->RH6_OUTEMP,"@E 9,999,999.99")		//INGRESOS GRAVADOS GENERADOS CON OTROS EMPLEADORES
	LI += 1
	@ Li,05 PSAY "DEDUCCI�N GASTOS PERSONALES CONSIDERADAS POR OTROS EMPLEADORES"
  	@ LI,100 PSAY "403   (-)"
	@ LI,115 PSAY Transform(RH6->RH6_OUTDED,"@E 9,999,999.99")		//(-) DEDUCCI�N GASTOS PERSONALES CONSIDERADAS POR OTROS EMPLEADORES
	LI += 1
	@ Li,05 PSAY "OTRAS REBAJAS CONSIDERADAS POR OTROS EMPLEADORES"
  	@ LI,100 PSAY "405   (-)"
	@ LI,115 PSAY Transform(RH6->RH6_OUTBXS,"@E 9,999,999.99")		//(-) OTRAS REBAJAS CONSIDERADAS POR OTROS EMPLEADORES
	LI += 1
	@ Li,05 PSAY "BASE IMPONIBLE TOTAL ANUAL"
  	@ LI,100 PSAY "407   (=)"
	@ LI,115 PSAY Transform(RH6->RH6_BASIMP,"@E 9,999,999.99")		//BASE IMPONIBLE TOTAL ANUAL
	LI += 1															//(351+401-403-405)
	@ Li,05 PSAY "IMPUESTO A LA RENTA CAUSADO"
  	@ LI,100 PSAY "409   (=)"
	@ LI,115 PSAY Transform(RH6->RH6_IMPCAU,"@E 9,999,999.99")		//IMPUESTO A LA RENTA CAUSADO
	LI += 1
	@ Li,05 PSAY "VALOR DEL IMPUESTO RETENIDO POR ESTE EMPLEADOR"
  	@ LI,100 PSAY "411   (=)"
	@ LI,115 PSAY Transform(RH6->RH6_IMPRET,"@E 9,999,999.99")		//VALOR DEL IMPUESTO RETENIDO POR ESTE EMPLEADOR
	LI += 1
	@ Li,05 PSAY "VALOR DEL IMPUESTO RETENIDO POR EMPLEADORES ANTERIORES DURANTE EL PER�ODO"
  	@ LI,100 PSAY "413   (=)"
	@ LI,115 PSAY Transform(RH6->RH6_OUTIMP,"@E 9,999,999.99")		//VALOR DEL IMPUESTO RETENIDO POR EMPLEADORES ANTERIORES DURANTE EL PER�ODO
	Li += 1
	@ Li,000 PSAY __PrtThinLine()
	Li += 30

	Return Nil
