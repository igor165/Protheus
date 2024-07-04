#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "GPER806.ch"

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  � GPER806    � Autor � Aemar Fernandes      � Data �  06/02/10   ���
�����������������������������������������������������������������������������͹��
���Descricao � Relatorio "Liquidacion anual de aportes y retenciones pre-     ���
���          � visionales"                                                    ���
�����������������������������������������������������������������������������͹��
���Uso       � Localizacao Peru                                               ���
�����������������������������������������������������������������������������͹��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                 ���
�����������������������������������������������������������������������������͹��
���Programador � Data   � FNC      � Motivo da Alteracao                      ���
�����������������������������������������������������������������������������͹��
���Leandro Dr. �16/03/12�    TEPNM0�Inclusao de help nos perguntes.           ���
���            �        �          �                                          ���
���Jonathan Glz�07/05/15�PCREQ-4256�Se elimina funcion AjustaSX1 la cual      ���
���            �        �          �realiza la modificacion a diccionario de  ���
���            �        �          �datos(SX1) por motivo de adecuacion nueva ���
���            �        �          �estructura de SXs para V12                ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Function GPER806()
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cDesc1	:= STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2	:= STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3	:= "Liquidacion anual de aportes y retenciones previsionales - Ley 27605"
Local cPict	:= ""
Local Titulo	:= "Liquidacion anual de aportes y retenciones previsionales - Ley 27605"
Local nLin		:= 80
Local Cabec1	:= ""
Local Cabec2	:= ""
Local imprime	:= .T.
Local aOrd 	:= {}
Local cPerg 	:= "GPR806"

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 80
Private tamanho     := "P"
Private nomeprog    := "GPER806" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { STR0003, 1, STR0004, 2, 2, 1, "", 1}	 //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "GPER806" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SRA"

dbSelectArea("SRA")
dbSetOrder(1)

Pergunte(cPerg,.F.)

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

/*
��������������������������������������������������������������Ŀ
� Variaveis utilizadas para parametros                         �
� mv_par01        //  Ano?      					           �
� mv_par02        //  Filial De?					           �
� mv_par03        //  Filial Ate?                              |
� mv_par04        //  AFP De?             	                   �
� mv_par05        //  AFP Ate?                                 �
� mv_par06        //  Direccion                                �
� mv_par07        //  Representante Legal                      �
� mv_par08        //  Cargo Representante Legal                �
� mv_par09        //  DNI Representante Legal                  �
����������������������������������������������������������������
��������������������������������������������������������������Ŀ
� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
����������������������������������������������������������������*/
cAno		:= mv_par01	//04
cFilDe      := mv_par02 //02
cFilAte     := mv_par03 //02
cAFPDe      := mv_par04 //02
cAFPAte     := mv_par05 //02
cDireccion  := mv_par06 //30
cNomeRepre  := mv_par07 //30
cCargRepre  := mv_par08 //30
cDNIRepre   := mv_par09 //20

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������
RptStatus({|| RunReport(Titulo,Cabec1,Cabec2,nLin) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  14/01/10   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RunReport(Titulo,Cabec1,Cabec2,nLin)

Local cQuery  := ""
Local aQtdAFP := {}
Local NPOS    := 0
Local cRUC    := fTabela("S015",01,05)
Local nX      := 0

Local cChvFunc := ""
Local nTotFunc := 0
Local lImpFiliado := .F.
Local lImpNaoFiliado := .F.

//���������������������������������������������������������������������Ŀ
//� Verifica quantas AFP existem no Cad.Funcionarios                    �
//�����������������������������������������������������������������������
If Select("QSRA") > 0
	QSRA->(dbCloseArea())
Endif

cQuery := "SELECT DISTINCT RA_CODAFP "
cQuery += "FROM "+RetSqlName("SRA")+" SRA "
cQuery += "WHERE SRA.D_E_L_E_T_ = ' ' "
cQuery += "AND RA_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' "
cQuery += "AND RA_CODAFP BETWEEN '"+cAFPDe+"' AND '"+cAFPAte+"' "
cQuery := ChangeQuery(cQuery)

TCQUERY cQuery NEW ALIAS "QSRA"

QSRA->(dbGotop())
While !EOF()

	If !Empty(RA_CODAFP)
		aAdd(aQtdAFP, {	RA_CODAFP, ;	//01-Codigo AFP
						"", ;			//02-Descricao AFP
						0, ;			//03-Filiado-Qtdade Funcionarios
						0, ;			//04-Filiado-Total de Aportes
						0, ;			//05-Nao Filiado-Qtdade Funcionarios
						0 })			//06-Nao Filiado-Total de Aportes
	EndIf

	dbSkip()
EndDo

//���������������������������������������������������������������������Ŀ
//� Armazenar os dados necessarios por AFP                              �
//�����������������������������������������������������������������������
For nX := 1 to Len(aQtdAFP)

	//# Armazena o Nome da AFP
	NPOS := FPOSTAB("S004", aQtdAFP[nX,01], "==", 04)

	IF NPOS > 0

		aQtdAFP[nX,02] := fTabela("S004",NPOS,05)

	ENDIF

Next nX

//���������������������������������������������������������������������Ŀ
//� Verifica o cancelamento pelo usuario...                             �
//�����������������������������������������������������������������������
If lAbortPrint
	@nLin,001 PSAY STR0005 //"*** CANCELADO PELO OPERADOR ***"
	Return
Endif

//���������������������������������������������������������������������Ŀ
//� Impressao do cabecalho do relatorio. . .                            �
//�����������������������������������������������������������������������
For nX := 1 to Len(aQtdAFP)

	//���������������������������������������������������������������������Ŀ
	//� Filtra os movimentos de AFP feitas pelo funcionario                 �
	//�����������������������������������������������������������������������
	If Select("QSRA") > 0
		QSRA->(dbCloseArea())
	Endif

	cQuery := "SELECT RD_FILIAL,RD_MAT,RD_PD,RD_DATARQ,RD_HORAS,RD_VALOR,RV_CODFOL,RV_DESC,RA_CODAFP,RA_NOME,RA_CUSPP,RA_PRISOBR,RA_SECSOBR,RA_DEMISSA,RA_CODEPS "
	cQuery += "FROM "+RetSqlName("SRD")+" RD "
	cQuery += "INNER JOIN "+RetSqlName("SRV")+" RV ON RV.D_E_L_E_T_=' ' AND RV_COD=RD_PD AND RV_CODFOL IN ('0859','1116') "
	cQuery += "INNER JOIN "+RetSqlName("SRA")+" RA ON RA.D_E_L_E_T_=' ' AND RA_FILIAL=RD_FILIAL AND RA_MAT=RD_MAT AND RA_CODAFP='"+aQtdAFP[nX,01]+"' "
	cQuery += "WHERE RA.D_E_L_E_T_=' ' AND RD_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' "
	cQuery += "AND SUBSTRING(RD_DATARQ,1,4)='"+cAno+"' "
	cQuery += "ORDER BY RA_CODAFP,RD_FILIAL,RD_MAT,RD_DATARQ,RD_PD "
	cQuery := ChangeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS "QSRA"
	TcSetField("QSRA", "RA_DEMISSA", "D", 8, 0)

	QSRA->( dbGotop() )

	While QSRA->( !Eof() )

		If nLin > 70 // Salto de P�gina. Neste caso o formulario tem 70 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		@nLin,001 PSAY "Liquidacion anual de aportes y retenciones previsionales - Ley 27605"

		//���������������������������������������������������������������������Ŀ
		//� Cabecalho com dados da Empresa emissora                             �
		//�����������������������������������������������������������������������
		nLin += 2
		@nLin,001 PSAY "Empresa: " + SM0->M0_NOMECOM
		nLin += 1
		@nLin,001 PSAY "Direccion: " + cDireccion
		nLin += 1
		@nLin,001 PSAY "RUC: " + cRUC
		nLin += 1
		@nLin,001 PSAY "Telefono: " + SM0->M0_TEL
		nLin += 2
		@nLin,001 PSAY "Liquidacion correspondiente a los afiliados al Sistema Privado de Pensiones: "
		nLin += 1
		@nLin,001 PSAY aQtdAFP[nX,02]	//(Nombre de la AFP)

		//���������������������������������������������������������������������Ŀ
		//� Cabecalho com dados do Funcionario                                  �
		//�����������������������������������������������������������������������
		nLin += 2
		@nLin,001 PSAY "CUSPP: " + QSRA->RA_CUSPP
		nLin += 1
		@nLin,001 PSAY "Apellido Paterno: " + QSRA->RA_PRISOBR
		nLin += 1
		@nLin,001 PSAY "Apellido Materno: " + QSRA->RA_SECSOBR
		nLin += 1
		@nLin,001 PSAY "Nombres: " + QSRA->RA_NOME

		// Regua -------         1         2         3         4         5         6         7         8
		// Regua -------123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+
		// Regua -------Secuencia: 01            Aportes        Fecha de
		// Regua -------Septiembre/2009     999999,9999.99      99/99/99

		nCol01 := 001
		nCol02 := 021
		nCol03 := 041

		nLin += 2
		@nLin,nCol01 PSAY "Secuencia: 01"
		@nLin,nCol02 PSAY Space(05)+"Aportes"
		@nLin,nCol03 PSAY "Fecha de"

		nLin += 1
		@nLin,nCol01 PSAY " "
		@nLin,nCol02 PSAY " "
		@nLin,nCol03 PSAY "Cese"

		//���������������������������������������������������������������������Ŀ
		//� Imprime movimentos de AFP do funcionario                            �
		//�����������������������������������������������������������������������
		nTotFunc := 0
		cChvFunc := QSRA->( RD_FILIAL+RD_MAT )
		While !Eof() .And. QSRA->( RD_FILIAL+RD_MAT ) == cChvFunc

			If Substr(RD_DATARQ,5,2)=="01"
				nLin += 1
				@nLin,nCol01 PSAY "Enero/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=1,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR

			ElseIf Substr(RD_DATARQ,5,2)=="02"
				nLin += 1
				@nLin,nCol01 PSAY "Febrero/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=2,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR

			ElseIf Substr(RD_DATARQ,5,2)=="03"
				nLin += 1
				@nLin,nCol01 PSAY "Marzo/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=3,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR

			ElseIf Substr(RD_DATARQ,5,2)=="04"
				nLin += 1
				@nLin,nCol01 PSAY "Abril/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=4,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR

			ElseIf Substr(RD_DATARQ,5,2)=="05"
				nLin += 1
				@nLin,nCol01 PSAY "Mayo/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=5,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR

			ElseIf Substr(RD_DATARQ,5,2)=="06"
				nLin += 1
				@nLin,nCol01 PSAY "Junio/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=6,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR

			ElseIf Substr(RD_DATARQ,5,2)=="07"
				nLin += 1
				@nLin,nCol01 PSAY "Julio/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=7,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR

			ElseIf Substr(RD_DATARQ,5,2)=="08"
				nLin += 1
				@nLin,nCol01 PSAY "Agosto/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=8,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR

			ElseIf Substr(RD_DATARQ,5,2)=="09"
				nLin += 1
				@nLin,nCol01 PSAY "Septiembre/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=9,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR

			ElseIf Substr(RD_DATARQ,5,2)=="10"
				nLin += 1
				@nLin,nCol01 PSAY "Octubre/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=10,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR

			ElseIf Substr(RD_DATARQ,5,2)=="11"
				nLin += 1
				@nLin,nCol01 PSAY "Noviembre/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=11,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR

			ElseIf Substr(RD_DATARQ,5,2)=="12"
				nLin += 1
				@nLin,nCol01 PSAY "Diciembre/"+cAno
				@nLin,nCol02 PSAY Transform(QSRA->RD_VALOR, "@E 999999,9999.99")
				@nLin,nCol03 PSAY Iif(Month(QSRA->RA_DEMISSA)=12,dToc(QSRA->RA_DEMISSA)," ")
				nTotFunc += QSRA->RD_VALOR
			EndIf

			lFILIADO := IIF( !EMPTY(QSRA->RA_CODEPS), .T., .F.)

			QSRA->( dbSkip() )
		EndDo

		nLin += 1
		@nLin,nCol01 PSAY "TOTAL"
		@nLin,nCol02 PSAY Transform(nTotFunc, "@E 999999,9999.99")

		nLin += 4
		@nLin,001 PSAY "Firma representante legal: ______________________________"

		nLin += 2
		@nLin,001 PSAY "Fecha: ___/___/______"

		nLin += 2
		@nLin,001 PSAY "Nombre representante legal: " + cNomeRepre

		nLin += 2
		@nLin,001 PSAY "Cargo: " + cCargRepre

		nLin += 2
		@nLin,001 PSAY "DNI: " + cDNIRepre

		nLin:= 80

		//���������������������������������������������������������������������Ŀ
		//� Verifica se o funcionario eh Filiado a algum orgao                  �
		//�����������������������������������������������������������������������
		If lFILIADO	//Tem EPS e Essalud
			lImpFiliado := .T.
			aQtdAFP[nX,03] += 1
			aQtdAFP[nX,04] += nTotFunc

		Else		//Tem Essalud somente
			lImpNaoFiliado := .T.
			aQtdAFP[nX,05] += 1
			aQtdAFP[nX,06] += nTotFunc
		EndIf

	EndDo

	nTotFunc := 0

Next nX

//���������������������������������������������������������������������Ŀ
//� Imprime as paginas de totalizacao pra Filiados e Nao Filiados       �
//�����������������������������������������������������������������������
If lImpFiliado
	fImpFiliado(Titulo,Cabec1,Cabec2,nLin,aQtdAFP,cRUC,cAno)
EndIf
If lImpNaoFiliado
	fImpNaoFiliado(Titulo,Cabec1,Cabec2,nLin,aQtdAFP,cRUC,cAno)
EndIf

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������
SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GPER806  �Autor  �Microsiga           � Data �  04/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Faz a impressao do relatorio final para Filiados           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Funcao principal                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fImpFiliado(Titulo,Cabec1,Cabec2,nLin,aQtdAFP,cRUC,cAno)

Local nX := 1

//���������������������������������������������������������������������Ŀ
//� Verifica o cancelamento pelo usuario...                             �
//�����������������������������������������������������������������������
If lAbortPrint
	@nLin,001 PSAY STR0005 //"*** CANCELADO PELO OPERADOR ***"
	Return
Endif

//���������������������������������������������������������������������Ŀ
//� Impressao do cabecalho do relatorio. . .                            �
//�����������������������������������������������������������������������
For nX := 1 to Len(aQtdAFP)

	If aQtdAFP[nX,03] > 0

		If nLin > 70 // Salto de P�gina. Neste caso o formulario tem 70 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		@nLin,001 PSAY "Propuesta de estructura: Ley 27605"

		nLin += 3
		@nLin,001 PSAY "AFP: Constancia de entrega de liquidacion anual de aportes y retenciones al"
		nLin += 1
		@nLin,001 PSAY "Sistema Privado de Pensiones."

		nLin += 2
		@nLin,001 PSAY "ONP: Constancia de entrega de liquidacion anual de aportes y retenciones al"
		nLin += 1
		@nLin,001 PSAY "Sistema Nacional de Pensiones."

		nLin += 3
		@nLin,001 PSAY "AFP: " + aQtdAFP[nX,02]

		nLin += 2
		@nLin,001 PSAY "Ano: " + cAno

		nLin += 3
		@nLin,041 PSAY "Datos del Empleador"

		nLin += 1
		@nLin,001 PSAY "RUC"
		@nLin,041 PSAY cRUC

		nLin += 1
		@nLin,001 PSAY "Razon Social"
		@nLin,041 PSAY SM0->M0_NOMECOM

		nLin += 1
		@nLin,001 PSAY "Direccion"
		@nLin,041 PSAY cDireccion

		nLin += 1
		@nLin,001 PSAY "Telefono"
		@nLin,041 PSAY SM0->M0_TEL

		nLin += 1
		@nLin,001 PSAY "Numero de Trabajadores"
		@nLin,045 PSAY Transform(aQtdAFP[nX,03], "@E 999,999")

		nLin += 1
		@nLin,001 PSAY "Total Liquidacion Anual"
		@nLin,041 PSAY Transform(aQtdAFP[nX,04], "@E 999999,9999.99")

		nLin += 4
		@nLin,001 PSAY "Firma representante legal: ______________________________"

		nLin += 2
		@nLin,001 PSAY "Nombre representante legal: " + cNomeRepre

		nLin:= 80

	EndIf
Next nX

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GPER806  �Autor  �Microsiga           � Data �  04/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Faz a impressao do relatorio final para Nao Filiados       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Funcao principal                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fImpNaoFiliado(Titulo,Cabec1,Cabec2,nLin,aQtdAFP,cRUC,cAno)

Local nX := 1

//���������������������������������������������������������������������Ŀ
//� Verifica o cancelamento pelo usuario...                             �
//�����������������������������������������������������������������������
If lAbortPrint
	@nLin,001 PSAY STR0005 //"*** CANCELADO PELO OPERADOR ***"
	Return
Endif

//���������������������������������������������������������������������Ŀ
//� Impressao do cabecalho do relatorio. . .                            �
//�����������������������������������������������������������������������
For nX := 1 to Len(aQtdAFP)

	If aQtdAFP[nX,05] > 0

		If nLin > 70 // Salto de P�gina. Neste caso o formulario tem 70 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		@nLin,001 PSAY "Propuesta de estructura: Ley 27605"

		nLin += 3
		@nLin,001 PSAY "Constancia de entrega de liquidacion de aportes y retenciones a ESSALUD"

		nLin += 3
		@nLin,001 PSAY "AFP: " + aQtdAFP[nX,02]

		nLin += 2
		@nLin,001 PSAY "Ano: " + cAno

		nLin += 3
		@nLin,041 PSAY "Datos del Empleador"

		nLin += 1
		@nLin,001 PSAY "RUC"
		@nLin,041 PSAY cRuc

		nLin += 1
		@nLin,001 PSAY "Razon Social"
		@nLin,041 PSAY SM0->M0_NOMECOM

		nLin += 1
		@nLin,001 PSAY "Direccion"
		@nLin,041 PSAY cDireccion

		nLin += 1
		@nLin,001 PSAY "Telefono"
		@nLin,041 PSAY SM0->M0_TEL

		nLin += 1
		@nLin,001 PSAY "Numero de Trabajadores"
		@nLin,045 PSAY Transform(aQtdAFP[nX,05], "@E 999,999")

		nLin += 1
		@nLin,001 PSAY "Total Liquidacion Anual"
		@nLin,041 PSAY Transform(aQtdAFP[nX,06], "@E 999999,9999.99")

		nLin += 4
		@nLin,001 PSAY "Firma representante legal: ______________________________"

		nLin += 2
		@nLin,001 PSAY "Nombre representante legal: " + cNomeRepre

		nLin:= 80

	EndIf
Next nX

Return
