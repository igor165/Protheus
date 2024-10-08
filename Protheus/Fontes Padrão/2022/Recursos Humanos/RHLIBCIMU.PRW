#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "RHLIBCIMU.ch"

#DEFINE CRMARCA  1
#DEFINE CRCORBRW 2
#DEFINE CRALIAS  3
#DEFINE CRNOME   4
#DEFINE CRROTINA 5
#DEFINE CRMODEL  6
#DEFINE CRFILTRO 7

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �RHLIBCIMU � Autor � Emerson Campos        � Data �30/01/2013|��
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de 'C'arga 'I'nicial via 'M'ensagem 'U'nica dos      ���
���          �registros que ja constam na base.                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Main Function RHLIBCIMU()

Local cFiltUsr
Local lEnd   		:= .F.
Local aSize     	:= {}
Local aObjects  	:= {}
Local aListBox  	:= {}
Local aInfo     	:= {}
Local aPosObj   	:= {}
Local aEmpMark		:= {}
Local oOk       	:= LoadBitMap(GetResources(),"LBOK")
Local oNo       	:= LoadBitMap(GetResources(),"LBNO")
Local oSay
Local oWS
Local oBtn01
Local oBtn02
Local bLineBkp

Private cEmpMark	:= ""
Private oVerde    	:= LoadBitmap( GetResources()	,	'BR_VERDE'		)
Private oAmarelo	:= LoadBitmap( GetResources()	,	'BR_AMARELO'	)
Private oListBox	:= Nil
Private oDlg		:= Nil
Private oQtdDoc		:= Nil
Private oQtdMrk		:= Nil
Private nQtdDoc		:= 0
Private nQtdMrk		:= 0
Private lExecAuto	:= .F.
//-- Checkbox
Private lAllMark	:= .F.   // Usado para o controle da marca de todos os documentos
//-- Rotinas Marcadas
Private aRotMark	:= {}

cArqEmp := "SigaMat.Emp"
nModulo	:= 09

__cInterNet := Nil

#IFDEF TOP
	TCInternal(5,'*OFF') //-- Desliga Refresh no Lock do Top
#ENDIF

Set DELETED On

//--ABERTURA DO SIGAMAT
OpenSm0()
DbGoTop()

dbSelectArea("SM0")
dbGoTop()

While !Eof()
	If ( aScan(aEmpMark,{ | x | x == SM0->M0_CODIGO }) ) == 0
		aAdd(aEmpMark,SM0->M0_CODIGO)
	EndIf
	DbSkip()
EndDo

CursorWait()
//-- Array com as rotinas a serem integradas GFE x TMS
Aadd(aListBox,{'2', oVerde,	'RBR',STR0001 ,'CSAA070','',NIL })	//Cadastro de Tabela Salarial
//Aadd(aListBox,{CRMARCA:='2', CRCORBRW := oVerde,	CRALIAS:='SA2',CRNOME:= STR0002 ,CRROTINA:='GPEA210',CRMODEL:='',            CRFILTRO:=NIL })	//Movimento Mensal
//Aadd(aListBox,{CRMARCA:='2', CRCORBRW := oVerde,	CRALIAS:='SRA',CRNOME:= STR0003 ,CRROTINA:='GPEA010',CRMODEL:='',            CRFILTRO:=NIL })   //Cadastro de Funcion�rios
//Aadd(aListBox,{CRMARCA:='2', CRCORBRW := oVerde,	CRALIAS:='CTT',CRNOME:= STR0004 ,CRROTINA:='CTBA030',CRMODEL:='CTBA030_CTT', CRFILTRO:=NIL })   //Cadastro de Centro de Custo

CursorArrow()

DEFINE WINDOW oMainWnd FROM 0,0 TO 10,10

aSize    := MsAdvSize(.F. )
aObjects := {}

AAdd( aObjects, { 100, 020, .T., .F., .T.  } )
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 020, .F., .F. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3, .T.  }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE STR0008 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)

@ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0009 SIZE 168, 08; //-- Marca/Desmarca Todos
ON CLICK(CIMUAll(aListBox)) OF oPanel PIXEL

@ 005,090 SAY STR0027 SIZE 168, 08 OF oPanel PIXEL//Empresa

@ 005,115 MSCOMBOBOX oEmpMark VAR cEmpMark ITEMS aEmpMark SIZE 168, 08 OF oPanel PIXEL //Empresa 

//-- Cabecalho dos campos do Monitor.
@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER;
"","",STR0010,STR0011, STR0012 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL

oListBox:SetArray( aListBox )
oListBox:bLDblClick := { || CIMUMrk(aListBox) }
oListBox:bLine      := { || {	Iif(aListBox[ oListBox:nAT,CRMARCA ] == '1',oOk,oNo),;
aListBox[ oListBox:nAT,CRCORBRW],;
aListBox[ oListBox:nAT,CRALIAS ],;
aListBox[ oListBox:nAT,CRROTINA],;
aListBox[ oListBox:nAT,CRNOME  ]}}

//-- Botoes da tela do monitor.
@ aPosObj[3,1],aPosObj[3,4] - 100 BUTTON oBtn01 	PROMPT STR0013  ACTION CIMULeg()			OF oDlg PIXEL SIZE 035,011	//-- "Legenda"
@ aPosObj[3,1],aPosObj[3,4] - 060 BUTTON oBtn02 	PROMPT STR0014	ACTION Iif(MsgYesNo(STR0015,STR0008),;                  //--"Confirma o Processamento", "Carga Inicial"
MsAguarde( { || CIMUProc(aListBox,@lEnd),MsgInfo(STR0026) }, STR0018 ),'') 					OF oDlg PIXEL SIZE 035,011	//-- "Transmitindo para o EAI" ## //"Processamento da carga finalizado. Consulte o monitor do Schedule para verificar eventuais erros!"
@ aPosObj[3,1],aPosObj[3,4] - 020 BUTTON oBtn03 	PROMPT STR0019	ACTION CIMUFil(@aListBox)   OF oDlg PIXEL SIZE 035,011	//-- "Filtro"
@ aPosObj[3,1],aPosObj[3,4] + 020 BUTTON oBtn04 	PROMPT STR0020	ACTION oDlg:End()  			OF oDlg PIXEL SIZE 035,011	//-- "Sair"

ACTIVATE MSDIALOG oDlg CENTERED

Return ( Nil )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CIMULeg   � Autor �Emerson Campos         �Data  �30/01/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina da Legenda do Filtro da Rotina                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CIMULeg()

BrwLegenda( STR0023		, STR0019,;				//--	"Status do Doc." # "Status"
{{'BR_AMARELO' , STR0021 },;  		//-- N�o Transmitido
{'BR_VERDE'    , STR0022 }})  		//-- Documento Aguardando

Return NIL

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CIMUMrk  � Autor � Emerson Campos        �Data  �30/01/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca as rotinas no listbox                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CIMUMrk()    		                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RHLIBCIMU                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function CIMUMrk(aListBox,nItem,lRefresh,lUmItem,lRetMark)

Local   nPosMrk := 0
Local	nDocMrk := 0

Default nItem   := oListBox:nAt
Default lRefresh:= .T.
Default lUmItem := .T.
Default lRetMark:= .F.

If lUmItem
	aListBox[nItem,CRMARCA] := Iif(aListBox[nItem,CRMARCA] == '1','2','1')
	If(aListBox[nItem,CRMARCA]) == '1'
		nQtdMrk += 1
	ElseIf(aListBox[nItem,CRMARCA]) == '2'
		nQtdMrk -= 1
	EndIf
Else
	If lAllMark
		aListBox[nItem,CRMARCA] := '1'
		nQtdMrk += 1
	Else
		aListBox[nItem,CRMARCA] := '2'
		nQtdMrk := 0
	EndIf
EndIf
nPosMrk := Ascan(aRotMark,{ | e | e[1]+e[2] == aListBox[nItem,CRALIAS]+aListBox[nItem,CRROTINA] })
If nPosMrk == 0
	Aadd(aRotMark,{ aListBox[nItem,CRROTINA], aListBox[nItem,CRALIAS], '' })
	nPosMrk := Len(aRotMark)
EndIf
aRotMark[nPosMrk,3] := aListBox[nItem,CRMARCA]
If lRefresh
	oListBox:Refresh()
EndIf

Return NIL

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CIMUAll  � Autor � Emerson Campos        �Data  �30/01/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca/Desmarca todas as rotinas                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CIMUAll()    		                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RHLIBCIMU                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function CIMUAll(aListBox)

Local nI      := 0
Local lRefresh:= .T.
Local lUmItem := .F.

CursorWait()
nQtdMrk := 0

For nI := 1 To Len(aListBox)
	CIMUMrk(aListBox,nI,lRefresh,lUmItem)
Next nI

CursorArrow()

oListBox:Refresh()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CIMUProc  � Autor �Emerson Campos         �Data  �30/01/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel por enviar as tabelas para MaEnvEAI      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nil													      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Param[1] - Array contendo as rotinas da tela			      ���
���			 �															  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CIMUProc(aListBox,lEnd)

Local   nI			:= 0
Local   aCargaIni	:= {}
Local   aGetArea	:= GetArea()
//Local   lModel	:= .F.

Private INCLUI    	:= .T.
Private ALTERA    	:= .F.
Private oModelCarga	:= Nil

Default aListBox  := {}

RpcSetType(3) //3=Nao consome licenca de uso
RpcSetEnv(cEmpMark)

aCargaIni := CIMURot(aListBox)

For nI := 1 To Len(aCargaIni)
	dbSelectArea(aCargaIni[nI,CRALIAS])
	dbGoTop()
	
	/*Esta fun��o retorna o nome de um arquivo de trabalho que ainda n�o existe e dependendo dos par�metros passados,
	pode criar um novo arquivo de trabalho.*/
	cIndAlias := CriaTrab( Nil, .F. )
	
	/*Esta fun��o cria um �ndice tempor�rio para o alias especificado, podendo ou n�o ter um filtro, e,
	tamb�m, podendo ser decrescente se o par�metro xOrdem for especificado como �D�.
	Durante a cria��o do �ndice um di�logo com uma barra de progress�o ser� criado, podendo esta ser omitido.*/
	IndRegua((aCargaIni[nI,CRALIAS]), cIndAlias, IndexKey(), , aCargaIni[nI,CRFILTRO],STR0024) //--"Selecionando Registros..."
	
	/*A fun��o RETINDEX() restaura os �ndices padr�es de um alias definidos no Dicion�rio de Dados (SIX)*/
	nIndAlias := RetIndex(aCargaIni[nI,CRALIAS])
	
	DbSetOrder( nIndAlias + 1 )
	ProcRegua( (aCargaIni[nI,CRALIAS])->( RecCount() ) )
	While (!(aCargaIni[nI,CRALIAS])->(Eof()))
		IncProc()
		
		If FWHasEai( aCargaIni[nI,CRROTINA],,,.T.)
			RegToMemory(aCargaIni[nI,CRALIAS],.F.)
			cFilAnt := &(aCargaIni[nI,CRALIAS] + "->" + PrefixoCpo(aCargaIni[nI,CRALIAS]) + "_" + "FILIAL")
			FWIntegDef(aCargaIni[nI,CRROTINA])
		EndIf
		
		(aCargaIni[nI,CRALIAS])->(dbSkip())
	EndDo
	
	If	File( cIndAlias + OrdBagExt() )
		DbSelectArea((aCargaIni[nI,CRALIAS]))
		DbClearFilter()
		Ferase( cIndAlias + OrdBagExt() )
	EndIf
	
	RetIndex((aCargaIni[nI,CRALIAS]))
	
Next nI

RestArea(aGetArea)

RpcClearEnv()

Return ( Nil )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CIMURot   � Autor � Emerson Campos        �Data  �30/01/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Preparar rotinas para processamento                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Retorna as rotinas selecionadas.                           ���
���          � Array dos documentos                                       ���
���          � [1] - Marca/Desmarca                                       ���
���          � [2] - Cor Legenda                                          ���
���          � [3] - Alias			                                      ���
���          � [4] - Nome do Alias 			                              ���
���          � [5] - Rotina        			                              ���
���          � [6] - Model        			                              ���
���          � [7] - Filtro       			                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CIMURot(aListBox)

Local   nI         := 0
Local   aRotProc 	 := {}

For nI := 1 To Len(aListBox)
	If aListBox[nI,CRMARCA] == '1'
		Aadd(aRotProc, {aListBox[nI,CRMARCA],aListBox[nI,CRCORBRW],aListBox[nI][CRALIAS],aListBox[nI][CRNOME], aListBox[nI][CRROTINA], aListBox[nI][CRMODEL], aListBox[nI][CRFILTRO]} )
	EndIf
Next nI

Return ( aRotProc )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CIMUFil   � Autor � Emerson Campos        �Data  �30/01/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Preparar rotinas para processamento                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Array dos documentos                                       ���
���          � [1] - Marca/Desmarca                                       ���
���          � [2] - Cor Legenda    		                              ���
���          � [3] - Alias				                                  ���
���          � [4] - Nome do Alias 			                              ���
���          � [5] - Rotina        			                              ���
���          � [6] - Model        			                              ���
���          � [7] - Filtro       			                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CIMUFil(aListBox)

Default aListBox := {}

aListBox[oListBox:nAT,CRFILTRO] := BuildExpr( aListBox[ oListBox:nAT,CRALIAS ], ,aListBox[oListBox:nAT,CRFILTRO])

If !Empty(aListBox[oListBox:nAT,CRFILTRO] )
	aListBox[ oListBox:nAT,CRCORBRW] := oAmarelo
	oListBox:Refresh()
Else
	aListBox[ oListBox:nAT,CRCORBRW] := oVerde
	oListBox:Refresh()
EndIf

Return ( Nil )
