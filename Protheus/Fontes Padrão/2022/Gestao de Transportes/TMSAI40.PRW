#include "PROTHEUS.ch"
#include "TMSAI40.ch"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSAI40   � Autor � Richard Anderson   � Data � 22/11/06 ���
��������������������������������������������������������������������������͹��
���             	Carta de Corre��o do CRT                    		         ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSAI40()                                                ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			         ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SIGATMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario �                                                           ���
���            �                                                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function TMSAI40()

Private cCadastro	:= STR0001 //-- "Carta de Corre��o do CRT"

//Private aImpRotina:= {{ STR0008  , "TMAI40I1"  , 0, 6 },; //"Carta"
// 				          { STR0009  , "TMAI40I2"  , 0, 6 }}  //"Carta Gr�fica"

Private aImpRotina:= {{ STR0008  , "TMAI40I1"  , 0, 6 }} //"Carta"

Private aRotina	:= {{ STR0002  , "AxPesqui"  , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMAI40Mnt" , 0, 2 },; //"Visualizar"
 				          { STR0004  , "TMAI40Mnt" , 0, 3 },; //"Incluir"
				          { STR0005  , "TMAI40Mnt" , 0, 5 },; //"Excluir"
 				          { STR0006  , aImpRotina , 0, 6 }}  //"Imprimir"  

DTQ->(dBGobottom()) //-- Forca o Eof da viagem para o F3 DL4 funcionar
DTQ->(dBSkip())
dbSelectArea("DIC")
dbSetOrder(1)
dbGoTop()


If	ExistBlock("RTMSR22")
	AAdd(aImpRotina,{ STR0009  , "TMAI40I2"  , 0, 6 })
EndIf

mBrowse(06,01,22,75,"DIC")

Return Nil

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI40Mnt � Autor � Richard Anderson     � Data �22.11.2007 ���
��������������������������������������������������������������������������Ĵ��
���          � Interface da Rotina de Carta de Corre��o                    ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Alias da tabela                                      ���
���          � ExpN2: Numero do Registro                                   ���
���          � ExpN3: Opcao do aRotina                                     ���
��������������������������������������������������������������������������Ĵ��
���Uso       � TMSAI40                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI40Mnt(cAlias, nReg, nOpcx)

Local nI       := 0
Local oFont    := TFont():New( "Courier New", 6, 15 )
Local aAreaAtu := GetArea()
Local nTLinhas := 0

//-- EnchoiceBar
Local aTmsVisual	:= {}
Local aTmsAltera	:= {}
Local nOpcA			:= 0
Local nOpcB       := aRotina[nOpcx,4]
Local oTmsEnch

//-- Dialog
Local oTmsDlgEsp
Local aNoFields	:= {}
Local aYesFields	:= {}

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}

//-- GetDados
Local nNumLinhas  := 999

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

//-- GetDados
Private oTmsGetD
Private aHeader	 := {}
Private aCols	    := {}
Private aTmsPosObj := {}

//-- Objeto LISTBOX
Private oLbx1
Private cLbx1

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, INCLUI )

//-- Determina campos que n�o aparecem na GETDADOS
Aadd(aNoFields,'DIM_FILDOC')
Aadd(aNoFields,'DIM_DOC')
Aadd(aNoFields,'DIM_SERIE')
Aadd(aNoFields,'DIM_SEQUEN')

//-- Configura variaveis da GetDados
TMSFillGetDados( nOpcx, 'DIM', 2, xFilial( 'DIM' ) + M->DIC_FILDOC+M->DIC_DOC+M->DIC_SERIE+M->DIC_SEQUEN, { || DIM->(DIM_FILIAL+DIM_FILDOC+DIM_DOC+DIM_SERIE+DIM_SEQUEN) },;
																		 { || .T. }, aNoFields,	aYesFields )
nTLinhas := Len(aCols)																			 
																			 
//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 060, .T., .T. } )
AAdd( aObjects, { 100, 040, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,, aTmsPosObj[1],, 3,,,,,,.T. )
	
	//-- Muda o fonte dos gets de campo Memo
	For nI := 1 To Len(oTmsEnch:aEntryCtrls)
		If oTmsEnch:aEntryCtrls[nI]:ClassName() == "TMULTIGET"
			oTmsEnch:aEntryCtrls[nI]:oFont := oFont
		EndIf
	Next nI

	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oTmsGetD := MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], nOpcx,'TMSAF40LOk','AllwaysTrue',,.T.,nil,nil,nil,nNumLinhas)	
ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar( oTmsDlgEsp,{|| IIf( Obrigatorio(aGets,aTela) .And. TMSAF40TOk(nOpcB),(nOpcA := 1, oTmsDlgEsp:End()),'') },{|| nOpcA := 0, oTmsDlgEsp:End() }) 

If nOpcB != 2 .And. nOpcA == 1
	TMAI40Grv(nOpcB)
EndIf

RestArea(aAreaATU)

Return nOpcA

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI40Vld� Autor � Richard Anderson      � Data �22/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida antes de editar o campo.                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMAI40Vld(cCampo) 

Local   lRet	  := .T.
Local   nI       := 0
Local   cDados   := ''
Local   aDadCli  := {}
Local   aAreaDT6 := DT6->(GetArea())
Local   cDocDIC  := ''

Default cCampo   := ReadVar()

If cCampo == 'M->DIC_FILDOC' .Or. cCampo == 'M->DIC_DOC' .Or. cCampo == 'M->DIC_SERIE'
	If !Empty(M->DIC_FILDOC) .And. !Empty(M->DIC_DOC) .And. !Empty(M->DIC_SERIE)
		DT6->(dbSetOrder(1))
		cDocDIC:=PadR(M->DIC_DOC,Len(DT6->DT6_DOC))
		If DT6->(!dbSeek(xFilial('DT6')+M->DIC_FILDOC+cDocDIC+M->DIC_SERIE))
			Help('',1,'REGNOIS')
			lRet := .F.
		EndIf
		If lRet .And. DT6->DT6_TIPTRA != StrZero(4,Len(DT6->DT6_TIPTRA))
			MsgAlert(STR0007) //-- "Documento n�o pertence ao transporte internacional"
			lRet := .F.
		EndIf
		If lRet
			aDadCli := TMSDadCli(DT6->DT6_CLIDES,DT6->DT6_LOJDES,2)
			For nI := 1 To Len(aDadCli)
				cDados += aDadCli[nI]+Chr(13)+Chr(10)
			Next nI				
			DIC->(dbSetOrder(1))
			DIC->(dbSeek(xFilial('DIC')+M->DIC_FILDOC+M->DIC_DOC+M->DIC_SERIE+Replicate('z',Len(DIC->DIC_SEQUEN)),.T.))
			DIC->(dbSkip(-1))
			If DIC->(Eof()) .Or. DIC->(DIC_FILDOC+DIC_DOC+DIC_SERIE) != M->DIC_FILDOC+M->DIC_DOC+M->DIC_SERIE
				M->DIC_SEQUEN := StrZero(1,Len(DIC->DIC_SEQUEN))
			Else
				M->DIC_SEQUEN := Soma1(DIC->DIC_SEQUEN)
			EndIf
		EndIf
		M->DIC_ENVCAR := cDados
	Else
		M->DIC_ENVCAR := CriaVar('DIC_ENVCAR')
	EndIf
ElseIf cCampo == 'M->DIM_CPODOC' .And. !Empty(M->DIM_CPODOC)
	lRet := ExistCpo('SX5','MO'+M->DIM_CPODOC,1)
	If lRet
		If M->DIM_CPODOC == "01" //-- Dados do Remetente
			aDadCli:= TMSDadCRT('01',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)
			cDados := ''
			For nI := 1 To Len(aDadCli)
				cDados += aDadCli[nI]+Chr(13)+Chr(10)
			Next nI
			M->DIM_DADREM := cDados
			GDFieldPut('DIM_ONDCTA',cDados)
			GDFieldPut('DIM_DEVCTA',cDados)
		ElseIf M->DIM_CPODOC == "04" //-- Dados do Destinatario
			aDadCli:= TMSDadCRT('04',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)
			cDados := ''
			For nI := 1 To Len(aDadCli)
				cDados += aDadCli[nI]+Chr(13)+Chr(10)
			Next nI
			GDFieldPut('DIM_ONDCTA',cDados)
			GDFieldPut('DIM_DEVCTA',cDados)
		ElseIf M->DIM_CPODOC == "05" //-- Localidade e Pais
			GDFieldPut('DIM_ONDCTA',TMSDadCRT('05',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)[1])
			GDFieldPut('DIM_DEVCTA',TMSDadCRT('05',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)[1])
		ElseIf M->DIM_CPODOC == "06" //-- Dados do Consignatario
			aDadCli:= TMSDadCRT('06',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)
			cDados := ''
			For nI := 1 To Len(aDadCli)
				cDados += aDadCli[nI]+Chr(13)+Chr(10)
			Next nI
			GDFieldPut('DIM_ONDCTA',cDados)
			GDFieldPut('DIM_DEVCTA',cDados)
		ElseIf M->DIM_CPODOC == "08" //-- Localidade de Entrega
			GDFieldPut('DIM_ONDCTA',TMSDadCRT('08',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)[1])
			GDFieldPut('DIM_DEVCTA',TMSDadCRT('08',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)[1])
		ElseIf M->DIM_CPODOC == "07" //-- Localidade da Mercadoria
			GDFieldPut('DIM_ONDCTA',TMSDadCRT('07',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)[1])
			GDFieldPut('DIM_DEVCTA',TMSDadCRT('07',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)[1])
		ElseIf M->DIM_CPODOC == "09" //-- Dados do Cliente a Notificar
			aDadCli:= TMSDadCRT('09',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)
			cDados := ''
			For nI := 1 To Len(aDadCli)
				cDados += aDadCli[nI]+Chr(13)+Chr(10)
			Next nI
			GDFieldPut('DIM_ONDCTA',cDados)
			GDFieldPut('DIM_DEVCTA',cDados)
		ElseIf M->DIM_CPODOC == "11" //-- Quantidade e categoria de volumes
			aDadCRT:= TMSDadCRT('11',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)
			cDados := ''
			For nI := 1 To Len(aDadCRT)
				cDados += aDadCRT[nI]+Chr(13)+Chr(10)
			Next nI
			GDFieldPut('DIM_ONDCTA',cDados)
			GDFieldPut('DIM_DEVCTA',cDados)
		ElseIf M->DIM_CPODOC == "12" //--  Peso bruto em Kg
			aDadCRT:= TMSDadCRT('12',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)
			cDados := ''
			If Len(aDadCRT) > 0
				aDadCRT[1] := 'Bruto..: '+Transform(aDadCRT[1] ,"@E 999,999.999" )
				aDadCRT[2] := 'Neto...: '+Transform(aDadCRT[2] ,"@E 999,999.999" )
				cDados += aDadCRT[1]+Chr(13)+Chr(10)
				cDados += aDadCRT[2]+Chr(13)+Chr(10)
			EndIf
			GDFieldPut('DIM_ONDCTA',cDados)
			GDFieldPut('DIM_DEVCTA',cDados)
		ElseIf M->DIM_CPODOC == "14" //--  Valor
			aDadCRT:= TMSDadCRT('14',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)
			cDados := ''
			If Len(aDadCRT) > 0
				cDados := aDadCRT[2] + " " + AllTrim(aDadCRT[1])
			EndIf
			GDFieldPut('DIM_ONDCTA',cDados)
			GDFieldPut('DIM_DEVCTA',cDados)
		ElseIf M->DIM_CPODOC == "15" //-- Frete
		  	TMAI40Frt()
		ElseIf M->DIM_CPODOC == "16" //--  Valor da Mercadoria
			aDadCRT:= TMSDadCRT('16',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)
			cDados := ''
			If Len(aDadCRT) > 0
				cDados := aDadCRT[2] + " " + AllTrim(aDadCRT[1])
			EndIf
			GDFieldPut('DIM_ONDCTA',cDados)
			GDFieldPut('DIM_DEVCTA',cDados)
		ElseIf M->DIM_CPODOC == "17" //-- Documentos Anexos
			aDadCRT:= TMSDadCRT('17',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)
			cDados := ''
			For nI := 1 To Len(aDadCRT)
				cDados += aDadCRT[nI]+Chr(13)+Chr(10)
			Next nI
			GDFieldPut('DIM_ONDCTA',cDados)
			GDFieldPut('DIM_DEVCTA',cDados)
		ElseIf M->DIM_CPODOC == "18" //-- Instrucoes de Alfandega
			aDadCRT:= TMSDadCRT('18',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)
			cDados := ''
			For nI := 1 To Len(aDadCRT)
				cDados += aDadCRT[nI]+Chr(13)+Chr(10)
			Next nI
			GDFieldPut('DIM_ONDCTA',cDados)
			GDFieldPut('DIM_DEVCTA',cDados)
		ElseIf M->DIM_CPODOC == "22" //-- Declaracoes e Observacoes
			aDadCRT:= TMSDadCRT('22',M->DIC_FILDOC,M->DIC_DOC,M->DIC_SERIE)
			cDados := ''
			For nI := 1 To Len(aDadCRT)
				cDados += aDadCRT[nI]+Chr(13)+Chr(10)
			Next nI
			GDFieldPut('DIM_ONDCTA',cDados)
			GDFieldPut('DIM_DEVCTA',cDados)                         \
		EndIf		
	EndIf		
EndIf

RestArea(aAreaDT6)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI40Whe� Autor � Richard Anderson      � Data �22/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Habilita a digitacao do campo                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMAI40Whe(cCampo) 

Local   lRet	:= .T.

Default cCampo := ReadVar()

If cCampo $ 'M->DIM_VALCIF'
	If GDFieldGet('DIM_CPODOC') == '15' .And. DT6->DT6_TIPFRE == '1'		// -Tipo CIF
		lRet := .T.
	Else
		lRet := .F.
	EndIf
ElseIf cCampo $ 'M->DIM_VALFOB'
	If GDFieldGet('DIM_CPODOC') == '15' .And. DT6->DT6_TIPFRE == '2'		// -Tipo FOB
		lRet := .T.
	Else
		lRet := .F.
	EndIf
EndIf

If cCampo $ 'M->DIM_VALCTA'
	If GDFieldGet('DIM_CPODOC') == '15'
		lRet := .F.
	Else
		lRet := .T.
	EndIf
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI40Grv� Autor � Richard Anderson      � Data �22/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida antes de editar o campo.                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMAI40Grv(nOpcx)

Local nCntFor	:= 0
Local nCntFo1	:= 0    
Local nValNovo	:= 0
Local nValOri	:= 0
Local lRet		:=.T.
Local cNumDc	:= ''
Local cValCif	:= ''
Local cValFob	:= ''

If	nOpcx == 5
	Begin Transaction
	RecLock('DIC', .F.)   // Exclui o Cabecalho
	DbDelete()
	MsUnLock()
	
	DIM->(dbSetOrder(2))
	While DIM->(dbSeek(xFilial('DIM')+DIC->(DIC_FILDOC+DIC_DOC+DIC_SERIE+DIC_SEQUEN)))
		RecLock('DIM',.F.)
		DbDelete()
		MsUnLock()
	EndDo
	End Transaction
Else
	Begin Transaction
	
	RecLock( "DIC", nOpcx == 3 )
	
	Aeval( dbStruct(), { |aFieldName, nI | FieldPut( nI, If('FILIAL' $ aFieldName[1],;
													   xFilial( "DIC" ), M->&(aFieldName[1]) ) ) } )

	MSMM(DIC->DIC_CODENV,,,M->DIC_ENVCAR,1,,,'DIC','DIC_CODENV')
	
	MsUnLock()
	
	For nCntFor := 1 To Len( aCols )
		If	!GDDeleted( nCntFor ) 
			RecLock('DIM',.T.)
			DIM->DIM_FILIAL := xFilial('DIM')
			DIM->DIM_FILDOC := M->DIC_FILDOC
			DIM->DIM_DOC    := M->DIC_DOC
			DIM->DIM_SERIE  := M->DIC_SERIE
			DIM->DIM_SEQUEN := M->DIC_SEQUEN
			For nCntFo1 := 1 To Len(aHeader)
				If	aHeader[nCntFo1,10] != 'V'
					FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
				EndIf
			Next              
			
			MSMM(DIM->DIM_CODDVC,,,GDFieldGet('DIM_DEVCTA',nCntFor),1,,,'DIM','DIM_CODDVC')
			MSMM(DIM->DIM_CODODC,,,GDFieldGet('DIM_ONDCTA',nCntFor),1,,,'DIM','DIM_CODODC')
			
			DIM->(MsUnLock())
						
		EndIf
	Next nCntFor

	If !Empty( DIM->DIM_VALCIF )
			
		nValNovo	:=	Val( MSMM( DIM->DIM_CODDVC, 80 ) )
		nValOri	:=	DIM->DIM_VALCIF
		
		If nValNovo > nValOri	//-- 'Debito'
			ctipo := '1'
		ElseIf nValNovo < nValOri	//-- 'Debito'			
			ctipo := '2'
		ElseIf nValNovo == nValOri	//-- 'Debito'							
			lRet	:= .F.
		EndIf
			
   	If lRet
			RegToMemory( 'DIH', INCLUI )
			
			M->DIH_FILIAL	:= xFilial('DIM')										//-- Filial
			M->DIH_FILDOC	:= DIM->DIM_FILDOC									//-- Filial do Documento
			M->DIH_DOC		:= DIM->DIM_DOC										//-- Numero do Documento
			M->DIH_SERIE	:= DIM->DIM_SERIE										//-- Serie do Documento
			M->DIH_FILORI	:= cFilAnt												//-- 	Filial de Origem         	
			M->DIH_DATEMI	:= dDataBase											//-- Data da Emissao          
			M->DIH_HOREMI	:= StrTran( Left( Time(), 5 ), ":", "" )		//-- Hora da Emissao          
			M->DIH_USER		:= RetCodUsr()											//-- Codigo do Usuario        
			M->DIH_NOMUSR	:= UsrFullName()										//-- Nome do Usuario          
			M->DIH_TIPNDC	:= cTipo													//-- Tipo Nota de 1 - Debito / 2 - Credito
			M->DIH_VALOR	:= nValNovo												//-- Valor Debito/Credito     
			M->DIH_MOTIVO	:= STR0010												//-- Motivo ## "Carta de Corre��o"
			M->DIH_ORINDC	:= '2'													//-- Origem Nota Debito/Credit
			M->DIH_STATUS	:= '2'													//-- Status                   

			cNumDc := TMAI60Grv( 3 )

			RecLock('DIC',.F.)
			DIC->DIC_NUMNDC := cNumDc
		MsUnLock()
	   EndIf
	   
   EndIf 
	End Transaction
EndIf

Return NIL     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMAI40Frt �Autor  �Telso Carneiro      � Data �  10/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Composisao do campo 15 (Frete)                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TMAI40Vld                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMAI40Frt()

Local	nI         := 0
Local oDlg       := {}
Local nOpcA      := 0
Local aNoFields  := {}
Local aYesFields := {}
Local oFolFrt
Local oGetDIA                      
Local nOpcx 	  := 3
Local cLinAcol   := ''
Local cLinAnew   := ''
Local cDescri    := ''
Local IncluiOLD  := INCLUI
Local lItemCIF   := .F.
Local lItemFOB   := .F.
Local nPosValCIF := 0
Local nPosValFOB := 0
Local cSimbMd    := ''

SaveInter()

//-- Composicao do Frete CIF/FOB
aHeader   := {}
aCols     := {}
Aadd(aNoFields,'DIA_FILORI')
Aadd(aNoFields,'DIA_LOTNFC')
Aadd(aNoFields,'DIA_FILDOC')
Aadd(aNoFields,'DIA_DOC'   )
Aadd(aNoFields,'DIA_SERIE' )

INCLUI  := .F.
TMSFillGetDados( 4,;
                 'DIA',;
  	              2    ,;
     	           xFilial('DIA')+M->DIC_FILDOC+M->DIC_DOC+M->DIC_SERIE,;
        	        { || DIA->(DIA_FILIAL+DIA_FILDOC+DIA_DOC+DIA_SERIE) },;
					  { || .T. },;
					  aNoFields ,;
				  	  aYesFields )     				  	  
INCLUI := .T. 

DIK->(DbSetOrder(4))
If DIK->(DbSeek(xFilial('DIK')+M->DIC_FILDOC+M->DIC_DOC+M->DIC_SERIE))
	RegToMemory('DIK',.F.)
EndIf

//--Correcoes para fretes zerados
//--Sempre verifico os dados, pois o usuario pode alterar os valores de frete
If Len(aCols) > 0
	nPosValCIF := GDFieldPos('DIA_VALCIF')
	nPosValFOB := GDFieldPos('DIA_VALFOB')
	If Ascan(aCols,{ | x | x[nPosValCIF] > 0}) > 0
		lItemCIF := .T.
	EndIf
	If Ascan(aCols,{ | x | x[nPosValFOB] > 0}) > 0
		lItemFOB := .T.
	EndIf
EndIf

//--Temos Componentes CIF e FOB
If lItemCIF .And. lItemFOB
	cLinAcol := STR0011 +Chr(13)+Chr(10) //--'Componente             Valor Remetente   Valor Destinat�rio'
EndIf
//--So componentes CIF
If lItemCIF .And. !lItemFOB
	cLinAcol := STR0012 +Chr(13)+Chr(10) //--'Componente             Valor Remetente'
EndIf
//--So componentes FOB
If !lItemCIF .And. lItemFOB
	cLinAcol := STR0013 +Chr(13)+Chr(10) //--'Componente             Valor Destinat�rio'
EndIf

cSimbMd := Padr(GetMv('MV_SIMB'+Str(DIK->DIK_MOEDA,1),,1),4)

For nI := 1 To Len(aCols)
	
	If GDFieldGet('DIA_CODPAS',nI) == 'TF'
		cDescri := Padr(STR0014,TamSx3('DT3_DESCRI')[1]) //--'TOTAL DO FRETE'
	Else
		cDescri := Padr(Posicione('DT3',1,xFilial('DT3')+GDFieldGet('DIA_CODPAS',nI),'DT3_DESCRI'),TamSx3('DT3_DESCRI')[1])
	EndIf

	//--Componentes CIF e FOB
	If lItemCIF .And. lItemFOB
		If GDFieldGet('DIA_VALCIF',nI) > 0 .Or. GDFieldGet('DIA_VALFOB',nI) > 0
			cLinAcol += cDescri+' '+;
							cSimbMd + TransForm(GDFieldGet('DIA_VALCIF',nI),'@E 999,999.99')+' '+;
							cSimbMd + TransForm(GDFieldGet('DIA_VALFOB',nI),'@E 999,999.99')+' '+;
							Chr(13)+Chr(10)
		EndIf
	EndIf

	//--So Componentes CIF com valores diferentes de zero	
	If lItemCIF .And. !lItemFOB
		If GDFieldGet('DIA_VALCIF',nI) > 0
			cLinAcol += cDescri+' '+ cSimbMd + TransForm(GDFieldGet('DIA_VALCIF',nI),'@E 999,999.99')+Chr(13)+Chr(10)
		EndIf
	EndIf

	//--So componentes FOB com valores diferentes de zero
	If !lItemCIF .And. lItemFOB
		If GDFieldGet('DIA_VALFOB',nI) > 0
			cLinAcol += cDescri+' '+ cSimbMd + TransForm(GDFieldGet('DIA_VALFOB',nI),'@E 999,999.99')+Chr(13)+Chr(10)
		EndIf
	EndIf
	
Next nI
  
DEFINE MSDIALOG oDlg TITLE STR0015 Of oMainWnd PIXEL  FROM 94 ,104 TO 330,825 //'Composi��o do Frete'

	oFolFrt:= TFolder():New(13,,{STR0016},{STR0016},oDlg,,,,.T.,.F.,oDlg:nWidth,oDlg:nHeight) //--'Frete &CIF/FOB'
	oFolFrt:Align := CONTROL_ALIGN_ALLCLIENT
	
	n      := 1
	oGetDIA:= MsGetDados():New(15,2,90,360,nOpcx,"TMAI70LOk(2)","AllwaysTrue",,.T.,,,,99,,,,,oFolFrt:aDialogs[1])
	oGetDIA:nMax := Len(aCols)
	oGetDIA:oBrowse:bDelete    := {|| .F. }  //-- Nao Permite a deletar Linhas
	oGetDIA:oBrowse:Default()	
	oGetDIA:oBrowse:Refresh()	
			
ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetDIA:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()}))

If nOpcA == 1

	//--Correcoes para fretes zerados
	//--Sempre verifico os dados, pois o usuario pode alterar os valores de frete
	nPosValCIF := GDFieldPos('DIA_VALCIF')
	nPosValFOB := GDFieldPos('DIA_VALFOB')
	If Ascan(aCols,{ | x | x[nPosValCIF] > 0}) > 0
		lItemCIF := .T.
	EndIf
	If Ascan(aCols,{ | x | x[nPosValFOB] > 0}) > 0
		lItemFOB := .T.
	EndIf
	
	//--Temos Componentes CIF e FOB
	If lItemCIF .And. lItemFOB
		cLinAnew := STR0011 +Chr(13)+Chr(10) //--"Componente             Valor Remetente   Valor Destinat�rio"
	EndIf
	//--So componentes CIF
	If lItemCIF .And. !lItemFOB
		cLinAnew := STR0012 +Chr(13)+Chr(10) //--"Componente             Valor Remetente"
	EndIf
	//--So componentes FOB
	If !lItemCIF .And. lItemFOB
		cLinAnew := STR0013 +Chr(13)+Chr(10) //--'Componente             Valor Destinat�rio'
	EndIf
	
	For nI := 1 To Len(aCols)
		
		If GDFieldGet('DIA_CODPAS',nI) == 'TF'
			cDescri := Padr(STR0014,TamSx3('DT3_DESCRI')[1]) //--'TOTAL DO FRETE'
		Else
			cDescri := Padr(Posicione('DT3',1,xFilial('DT3')+GDFieldGet('DIA_CODPAS',nI),'DT3_DESCRI'),TamSx3('DT3_DESCRI')[1])
		EndIf
	
		//--Componentes CIF e FOB
		If lItemCIF .And. lItemFOB
			If GDFieldGet('DIA_VALCIF',nI) > 0 .Or. GDFieldGet('DIA_VALFOB',nI) > 0
				cLinAnew += cDescri+' '+;
								cSimbMd + TransForm(GDFieldGet('DIA_VALCIF',nI),'@E 999,999.99')+' '+;
								cSimbMd + TransForm(GDFieldGet('DIA_VALFOB',nI),'@E 999,999.99')+' '+;
								Chr(13)+Chr(10)
			EndIf
		EndIf
	
		//--So Componentes CIF com valores diferentes de zero
		If lItemCIF .And. !lItemFOB
			If GDFieldGet('DIA_VALCIF',nI) > 0
				cLinAnew += cDescri+' '+ cSimbMd + TransForm(GDFieldGet('DIA_VALCIF',nI),'@E 999,999.99')+Chr(13)+Chr(10)
			EndIf
		EndIf
	
		//--So componentes FOB com valores diferentes de zero
		If !lItemCIF .And. lItemFOB
			If GDFieldGet('DIA_VALFOB',nI) > 0
				cLinAnew += cDescri+' '+ cSimbMd + TransForm(GDFieldGet('DIA_VALFOB',nI),'@E 999,999.99')+Chr(13)+Chr(10)
			EndIf
		EndIf
		
	Next nI

EndIf
              
INCLUI := IncluiOLD
RestInter()

GDFieldPut('DIM_ONDCTA',cLinAcol)
If cLinAnew != ''
	GDFieldPut('DIM_DEVCTA',cLinAnew)
EndIf

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMSAF40LOk�Autor  �Telso Carneiro      � Data �  17/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Linha OK                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSAF40LOk( nOpc )

Local lRet      := .T.
Local aCpoCheck := {'DIM_CPODOC'}
Local aCpoNoEmp := {'DIM_CPODOC'}
Local nCtn      := 0

//-- Analisa se ha itens duplicados na GetDados.
If !GDDeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	lRet := GDCheckKey(aCpoCheck,4)
EndIf

//-- Analisa se ha itens vazios na GetDados.
If !GDDeleted(n)
	For nCtn := 1 To Len(aCpoNoEmp)
		lRet := !Empty(GdFieldGet(aCpoNoEmp[nCtn],n))
		If !lRet
			Help('',1,'OBRIGAT',,aHeader[GdFieldPos(aCpoNoEmp[nCtn]),1],4,0)
			Exit
		EndIf
	Next
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMSAF40TOk�Autor  �Telso Carneiro      � Data �  17/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tudo OK                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSAF40TOk( nOpcx )

Local lRet    := .T.
Local nOld    := N
Local nI      := 0

If nOpcx <> 2
	For nI := 1 To Len(aCols)
		n := nI
		lRet := TMSAF40LOk( nOpcx )
		If !lRet
			Exit
		EndIf
	Next
EndIf

N := nOld

Return(lRet)
       
/*
Carta
*/
Function TMAI40I1()
If	ExistBlock("RTMSR19")
	ExecBlock("RTMSR19",.F.,.F.)
EndIf
Return
/*
Carta Grafica
*/
Function TMAI40I2()
If	ExistBlock("RTMSR22")
	ExecBlock("RTMSR22",.F.,.F.)
EndIf
Return
