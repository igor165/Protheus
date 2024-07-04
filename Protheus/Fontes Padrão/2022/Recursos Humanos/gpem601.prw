#Include "RwMake.ch"
#Include "Protheus.CH"   
#Include "HeaderGD.CH"
#Include "GPEM601.CH"

/* 
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������Ŀ��
���Funcao    � GPEM601  � Autor  � WAGNER MONTENEGRO                 � Data � 30/10/10 ���
��������������������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao das Tabelas de Dados do Homolognet                           ���
��������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                          ���
��������������������������������������������������������������������������������������Ĵ��
���Programador � Data   � Requisito         �  Motivo da Alteracao                     ���
��������������������������������������������������������������������������������������Ĵ��
���Bruno Nunes �29/01/14� 001975_01         � Unificacao da Homolognet da versao 11.80 ���
���            �        �                   � com a fase 4                             ���
���Gustavo M.  �24/05/16� TVDLPV         	� Correcao na pesquisa.					   ���
���C�cero Alves�28/04/17� DRHPAG-242        � Usar FWTemporaryTable para a cria��o  de ���
���			   �	    �          			� tabelas tempor�rias					   ���
���������������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������*/
Function GPEM601()
Private aRotina 	:= MenuDef()
Private aHom		:= {"RGW","RGW","RGW","RGX","RGZ","RGY"}
Private cCadastro 	:= STR0001 //"Homolognet"
Private aCampos 	:= {}
Private oFont 		:= TFont():New("Arial",, -11,, .T.,,,,, .F., .F.)
Private oTmpTable	:= Nil
Private oTmpRCC		:= Nil

Private aFldRot 	:= {'RA_NOME'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaNom 	:= .F. 
Private aFldOfusca	:= {} 

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
ENDIF

//�������������������������������������������������Ŀ
//�Carrega tabela temporia como tela inicial        �
//���������������������������������������������������
CarTelaIni(@aCampos)

//�������������������������������������������������Ŀ
//�Chama tabela temporaria em mBrowse               �
//���������������������������������������������������
dbSelectArea("TRB")
If TRB->(EOF()) .and. TRB->(BOF())		
	Help(" ",1,"RECNO")
Else	
	mBrowse( 6, 1, 22, 75, "TRB", aCampos,,,,, GPEM601LGD("TRB"))
Endif

//�������������������������������������������������Ŀ
//�Fecha tabela temporaria                          �
//���������������������������������������������������
If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
	oTmpTable:Delete()
EndIf
If Select("TMPTRB") > 0
	dbSelectArea("TMPTRB")
	dbCloseArea()
EndIf 

Return(Nil)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601MAN � Autor � Wagner Montenegro  � Data � 30/10/2010 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o de Manuten��o Homolognet		  					   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601MAN()                                                ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function GPEM601MAN( cAlias, nReg, nOpcX )
Local aIndexRGW		:= {}
Local aIndexRGX		:= {}
Local aIndexRGY		:= {}
Local aIndexRGZ		:= {}

Private aIndex		:= {} 
Private bFiltraRGW	:= {|| FilBrowse("RGW", @aIndexRGW, @cCondRGW)}
Private bFiltraRGX	:= {|| FilBrowse("RGX", @aIndexRGX, @cCondRGX)}
Private bFiltraRGY	:= {|| FilBrowse("RGY", @aIndexRGY, @cCondRGY)}
Private bFiltraRGZ	:= {|| FilBrowse("RGZ", @aIndexRGZ, @cCondRGZ)}

//������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
//� 							"Dados Iniciais", "Dados de F�rias", "Dados de 13�", "Dados Financeiros", "Movimenta��es", "Descontos da Rescis�o" �
//��������������������������������������������������������������������������������������������������������������������������������������������������
Private aFolder     := { STR0003, STR0004, STR0005, STR0006, STR0007, STR0008 }

//�������������������������������������������������Ŀ
//�Condicao do filtro                               �
//���������������������������������������������������
Private cCondRGW	:= "RGW_FILIAL=='"	+xFilial('RGW',TRB->RA_FILIAL)+"' .AND. RGW_MAT==TRB->RA_MAT" 
Private cCondRGX  	:= "RGX_FILIAL=='"	+xFilial('RGX',TRB->RA_FILIAL)+"' .AND. RGX_MAT==TRB->RA_MAT .AND. RGX_TPRESC=='1' .AND. RGX_HOMOL==TRB->RG_DATAHOM" 
Private cCondRGY  	:= "RGY_FILIAL=='"	+xFilial('RGY',TRB->RA_FILIAL)+"' .AND. RGY_MAT==TRB->RA_MAT .AND. RGY_TPRESC=='1' .AND. RGY_HOMOL==TRB->RG_DATAHOM" 
Private cCondRGZ  	:= "RGZ_FILIAL=='"	+xFilial('RGZ',TRB->RA_FILIAL)+"' .AND. RGZ_MAT==TRB->RA_MAT .AND. RGZ_TPRESC=='1' .AND. RGZ_HOMOL==TRB->RG_DATAHOM" 

//�������������������������������������������������Ŀ
//�Leitura da chave nas tabelas                     �
//���������������������������������������������������
RGW->(dbSeek(xFilial("RGW",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+'1'))
RGX->(dbSeek(xFilial("RGX",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)))
RGZ->(dbSeek(xFilial("RGZ",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)))
RGY->(dbSeek(xFilial("RGY",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)))

//�������������������������������������������������Ŀ
//�Executa Filtro                                   �
//���������������������������������������������������
Eval( bFiltraRGW )
Eval( bFiltraRGX )
Eval( bFiltraRGZ )
Eval( bFiltraRGY )

//�������������������������������������������������Ŀ
//� Carrega tela manutencao                         �
//���������������������������������������������������
CarTelaMenu(cAlias, nReg, nOpcX)

//�����������������������������������������������������������������������Ŀ
//� Limpa filtros                                                         �
//�������������������������������������������������������������������������
EndFilBrw("RGW",aIndexRGW)
EndFilBrw("RGX",aIndexRGX)
EndFilBrw("RGZ",aIndexRGZ)
EndFilBrw("RGY",aIndexRGY)

Return(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CarTelaIni � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function CarTelaIni(aCampos)
Local nX		:= 0
Local cString	:= "TMPTRB"
Local aStruSRA	:= {}
Local sStruSRG	:= {}
Local sStruRGW	:= {}
Local aStruct	:= {}
Local cIndex	:= ''
Local cNomeArq  := ''
Local cAliasTRB	:= "TRB"
Local aIndex	:= {}  
Local cMatRGW	:= ''
Local aOrdem	:= {}

aCampos := { ;
				{TitSX3("RA_FILIAL" )[1], "RA_FILIAL"	, "", TamSx3("RA_FILIAL")[1], 00, ""} ,; //Campo 01- SRA
				{TitSX3("RA_MAT"	)[1], "RA_MAT"		, "", TamSx3("RA_MAT"   )[1], 00, ""} ,; //Campo 02- SRA
				{TitSX3("RA_NOME"	)[1], "RA_NOME"	    , "", TamSx3("RA_NOME"  )[1], 00, ""} ,; //Campo 03- SRA
				{TitSX3("RA_CC"	    )[1], "RA_CC"  	    , "", TamSx3("RA_CC"    )[1], 00, ""} ,; //Campo 04- SRA
				{TitSX3("RG_DATADEM")[1], "RG_DATADEM"	, "", 10                    , 00, ""} ,; //Campo 06- SRG
				{TitSX3("RG_DATAHOM")[1], "RG_DATAHOM"	, "", 10                    , 00, ""} ,; //Campo 07- SRG
				{TitSX3("RGW_NUMID" )[1], "RGW_NUMID"	, "", TamSx3("RGW_NUMID")[1], 00, ""} ,; //Campo 08- RGW
				{TitSX3("RA_ADMISSA")[1], "RA_ADMISSA"	, "", 10                    , 00, ""} ,; //Campo 05- SRA
				{""				        , "GHOSTCOL"	, "", 00                    , 00, ""} ;
			}

dbSelectArea("SRA")
aStruSRA := dbStruct()
dbSelectArea("SRG")
aStruSRG := dbStruct()
dbSelectArea("RGW")
aStruRGW := dbStruct()

aAdd(aStruct,{aCampos[1][2], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[1][2]})][2], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[1][2]})][3], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[1][2]})][4]}) // FILIAL
aAdd(aStruct,{aCampos[2][2], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[2][2]})][2], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[2][2]})][3], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[2][2]})][4]}) // MATRICULA
aAdd(aStruct,{aCampos[3][2], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[3][2]})][2], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[3][2]})][3], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[3][2]})][4]}) // NOME
aAdd(aStruct,{aCampos[4][2], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[4][2]})][2], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[4][2]})][3], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[4][2]})][4]}) // CENTRO DE CUSTO
aAdd(aStruct,{aCampos[5][2], aStruSRG[ aScan(aStruSRG,{|x|x[1]==aCampos[5][2]})][2], aStruSRG[ aScan(aStruSRG,{|x|x[1]==aCampos[5][2]})][3], aStruSRG[ aScan(aStruSRG,{|x|x[1]==aCampos[5][2]})][4]}) // DEMISSAO
aAdd(aStruct,{aCampos[6][2], aStruSRG[ aScan(aStruSRG,{|x|x[1]==aCampos[6][2]})][2], aStruSRG[ aScan(aStruSRG,{|x|x[1]==aCampos[6][2]})][3], aStruSRG[ aScan(aStruSRG,{|x|x[1]==aCampos[6][2]})][4]}) // HOMOLOGACAO
aAdd(aStruct,{aCampos[7][2], aStruRGW[ aScan(aStruRGW,{|x|x[1]==aCampos[7][2]})][2], aStruRGW[ aScan(aStruRGW,{|x|x[1]==aCampos[7][2]})][3], aStruRGW[ aScan(aStruRGW,{|x|x[1]==aCampos[7][2]})][4]}) // NUM ID
aAdd(aStruct,{aCampos[8][2], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[8][2]})][2], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[8][2]})][3], aStruSRA[ aScan(aStruSRA,{|x|x[1]==aCampos[8][2]})][4]}) // ADMISSAO
aAdd(aStruct,{"GHOSTCOL"   , "C"                                                   , 1                                                     , 0                                                     })

oTmpTable := FWTemporaryTable():New("TRB")
oTmpTable:SetFields( aStruct )
aOrdem := {aCampos[1][2], aCampos[2][2]}
oTmpTable:AddIndex("IN1", aOrdem)
oTmpTable:Create()

cQuery	:= " SELECT DISTINCT  	"
cQuery	+= " 	SRA.RA_FILIAL,  "
cQuery	+= " 	SRA.RA_MAT,  	"
cQuery	+= " 	SRA.RA_NOME,  	"
cQuery	+= " 	SRA.RA_CC,  	"
cQuery	+= " 	SRG.RG_DATADEM, " 
cQuery	+= " 	SRA.RA_ADMISSA, "
cQuery	+= " 	SRG.RG_DATAHOM, "
cQuery	+= " 	RGW.RGW_NUMID,  "
cQuery	+= " 	SRA.RA_ADMISSA  "
cQuery	+= " FROM "
cQuery	+= " 	"+RETSQLNAME("SRA")+" SRA,"
cQuery	+= " 	"+RETSQLNAME("SRG")+" SRG,"
cQuery	+= " 	"+RETSQLNAME("RGW")+" RGW "
cQuery	+= " WHERE 	SRA.RA_FILIAL 	= SRG.RG_FILIAL  AND "
cQuery	+= "      	RGW.RGW_FILIAL 	= SRG.RG_FILIAL  AND "
cQuery	+= " 	  	SRG.RG_MAT     	= SRA.RA_MAT     AND "
cQuery	+= "		RGW.RGW_MAT 	= SRG.RG_MAT 	 AND "
cQuery	+= "      	RGW.RGW_HOMOL  	= SRG.RG_DATAHOM AND "
cQuery	+= "      	SRA.D_E_L_E_T_ 	= '' 			 AND "
cQuery	+= " 		SRG.D_E_L_E_T_ 	= '' 			 AND "
cQuery	+= " 		RGW.D_E_L_E_T_ 	= '' "
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cString, .F., .T.)	

TMPTRB->(dbGoTop())
If TMPTRB->(EOF()) .and. TMPTRB->(BOF())
   Help(" ",1,"RECNO")
Else	
	While !TMPTRB->(EOF())  
		If TMPTRB->RA_FILIAL $ fValidFil()                         
			If TRB->(RecLock("TRB",.T.))
				For nX := 1 to Len( aStruct )
					If aStruct[nX,1]<>"GHOSTCOL"
						if aStruct[nX,1] ==  'RA_NOME'
							TRB->( FieldPut( nX , If(lOfuscaNom,Replicate('*',15),&("TMPTRB->"+(aCampos[nX][2])) ) ) )
						ELSE
							TRB->( FieldPut( nX,If(aStruct[nX][2]=="D",STOD(&("TMPTRB->"+(aCampos[nX][2]))),&("TMPTRB->"+(aCampos[nX][2])) ) ) )
						ENDIF
					Endif
				Next
				TRB->(MsUnlock())
			Endif	
			
		Endif
		TMPTRB->(DbSkip())
	Enddo
	TRB->(DbGoTop())

Endif

Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CarTelaMenu� Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function CarTelaMenu(cAlias, nReg, nOpcX)
Local aAdvSize		:= {}
Local aObjSize		:= {}
Local aObj2Size		:= {}
Local aObj3Size		:= {}
Local aObj4Size		:= {}

Private oDlgGeral	:= Nil
Private oFolder		:= Nil
Private oPanel1 	:= Nil
Private oPanel2 	:= Nil
Private oPanel3 	:= Nil
Private oPanel4 	:= Nil
Private oPanel5 	:= Nil
Private oPanel6 	:= Nil
Private oBrowRGW2	:= Nil
Private oBrowRGW3	:= Nil
Private oBrowRGX 	:= Nil
Private oBrowRGY 	:= Nil
Private oBrowRGZ 	:= Nil
Private oSButInc2	:= Nil
Private oSButAlt2	:= Nil
Private oSButDel2	:= Nil
Private oSButCan	:= Nil
Private oSButInc3	:= Nil
Private oSButAlt3	:= Nil
Private oSButDel3	:= Nil
Private oSButInc4	:= Nil
Private oSButAlt4	:= Nil
Private oSButDel4	:= Nil
Private oSButInc5	:= Nil	
Private oSButAlt5	:= Nil
Private oSButDel5	:= Nil
Private oSButInc6	:= Nil
Private oSButAlt6	:= Nil
Private oSButDel6	:= Nil
Private aCpoRGW1	:= {}
Private aCpoRGW2	:= {}
Private aCpoRGW3	:= {}
Private aSizeRGW1	:= {}
Private aSizeRGW2	:= {}
Private aSizeRGW3	:= {}
Private aCpoRGX		:= {}
Private aCpoRGZ		:= {}
Private aCpoRGY		:= {}
Private aCpoEnch	:= {}
Private aAltRGW1	:= {}
Private aAltRGW2	:= {}
Private aAltRGW3	:= {}
Private aAltRGX		:= {}
Private aAltRGZ		:= {}
Private aAltRGY		:= {}
Private aAlterEnch	:= {}
Private aPadraoRGW	:= {}
Private aPadraoRGX	:= {}
Private aPadraoRGZ	:= {}
Private aPadraoRGY	:= {}
Private bRefresh	:= {|| .T.}
Private nOpca		:= 0

//�������������������������������������������������Ŀ
//� Carrega nos arrays posicoes dos objetos de tela �
//���������������������������������������������������
PosObjAba(@aObjSize, @aObj2Size, @aObj3Size, @aObj4Size, @aAdvSize)

//�������������������������������������������������Ŀ
//� Seta janela de manutencao                       �
//���������������������������������������������������
oDlgGeral := tDialog():New(aAdvSize[7], 0, aAdvSize[6], aAdvSize[5], STR0009,,,,,,,,, .T.) // "Manuten��o Homolognet"

//��������������������������������������������������Ŀ
//� Carrega campos do cabecalho da tela de manutencao�
//����������������������������������������������������	
TelaCabec(aObjSize, @oDlgGeral)

//�������������������������������������������������Ŀ
//� Seta objeto de abas abaixo do cabecalho         �
//���������������������������������������������������	
oFolder 	:= TFolder():New(aObjSize[2,1], aObjSize[2,2], aFolder, aFolder, oDlgGeral,,,, .T., ,aObjSize[2,3], aObjSize[2,4] )

//�������������������������������������������������Ŀ
//� Carrega variaveis dos campos                    �
//���������������������������������������������������	
RegToMemory('RGW', .F., .T.)
RegToMemory('RGX', .F., .T.)
RegToMemory('RGY', .F., .T.)
RegToMemory('RGZ', .F., .T.)

//�������������������������������������������������Ŀ
//� Carrega abas da tela de manutencao              �
//���������������������������������������������������	
CarPanel1(aObj2Size, cAlias, nReg, nOpcX)
CarPanel2(aObj3Size, cAlias, nReg, nOpcX)
CarPanel3(aObj3Size, cAlias, nReg, nOpcX)
CarPanel4(aObj3Size, cAlias, nReg, nOpcX)
CarPanel5(aObj3Size, cAlias, nReg, nOpcX)
CarPanel6(aObj3Size, cAlias, nReg, nOpcX)

//�����������������������������������������������������������������������Ŀ
//� Bloco de codigo chamado na troca de aba                               �
//�������������������������������������������������������������������������
oFolder:bSetOption	:= {|nAtu| GPEM601FLD(nAtu, oFolder:nOption, nReg, nOpcX, oDlgGeral, oFolder)}
bRefresh			:= {|| oDlgGeral:oFolder:Refresh() }

//�����������������������������������������������������������������������Ŀ
//� Seta botao cancelar na janela de dialago                              �
//�������������������������������������������������������������������������
oSButCan := SButton():New( aObjSize[3,1]+5, aObjSize[3,4]-25,2, {||oDlgGeral:End(), nOpca:=0}, oDlgGeral, .T.)

//�����������������������������������������������������������������������Ŀ
//� Apresenta o dialogo.                                                  �
//�������������������������������������������������������������������������
oDlgGeral:Activate (,,, .T.)

Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PosObjAba  � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function PosObjAba(aObjSize, aObj2Size, aObj3Size, aObj4Size, aAdvSize)
Local aObjCoords	:= {}
Local aInfoAdvSize	:= {}
Local aObj2Coords	:= {}
Local aAdv2Size		:= {}
Local aInfo2AdvSize := {}
Local aObj3Coords	:= {}
Local aAdv3Size		:= {}
Local aInfo3AdvSize := {}
Local aObj4Coords	:= {}
Local aAdv4Size		:= {}
Local aInfo4AdvSize := {}

//�������������������������������������������������Ŀ
//� Pega informacoes dos objetos em telas           �
//���������������������������������������������������
aAdvSize        := MsAdvSize()
aInfoAdvSize    := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 3 , 3 }
aAdd( aObjCoords , { 000 , 020 , .T. , .F.     } )
aAdd( aObjCoords , { 000 , 100 , .T. , .T. ,.T.} )
aAdd( aObjCoords , { 000 , 020 , .T. , .F.     } )
aObjSize    := MsObjSize( aInfoAdvSize , aObjCoords ) 

//�������������������������������������������������Ŀ
//� Utilizado na getdados da primeira aba do folder �
//���������������������������������������������������
aAdv2Size     := aClone(aObjSize[2])
aInfo2AdvSize := { 0 , 0 , aAdv2Size[4] , aAdv2Size[3] , 2 , 2 }
aAdd( aObj2Coords , { 000 , 100 , .T. , .T. } )
aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords)

//�������������������������������������������������Ŀ
//� Utilizado nas listbox das demais abas           �
//���������������������������������������������������
aAdv3Size     := aClone(aObjSize[2])
aInfo3AdvSize := { 0 , 0 , aAdv3Size[3] , aAdv3Size[4] , 2 , 2 }
aAdd( aObj3Coords , { 000 , 100 , .T. , .T., .T. } )
aAdd( aObj3Coords , { 000 , 040 , .T. , .F.      } )
aObj3Size := MsObjSize( aInfo3AdvSize , aObj3Coords )

//�������������������������������������������������Ŀ
//� Utilizado na getdados da primeira aba do folder �
//���������������������������������������������������
aAdv4Size     := aClone(aObj2Size[1])
aInfo4AdvSize := { 0 , 0 , aAdv4Size[3] , aAdv4Size[4] , 5 , 5 }
aAdd( aObj4Coords , { 000 , 000 , .T. , .T. } )
aObj4Size := MsObjSize( aInfo4AdvSize , aObj4Coords)
Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � TelaCabec  � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function TelaCabec(aObjSize, oDlgPai)
Local oGroupMat  := Nil 
Local oGroupNome := Nil 
Local oGroupAdi  := Nil
Local oSayMat    := Nil
Local oSayNome   := Nil
Local oSayAdi    := Nil
 
oGroupMat  := TGroup():Create( oDlgPai, aObjSize[1][1], aObjSize[1][2]	      , aObjSize[1][3], aObjSize[1][4] * 0.18, TitSX3("RA_MAT")[1]    ,,, .T.) // "Matricula:" 
oGroupNome := TGroup():Create( oDlgPai, aObjSize[1][1], aObjSize[1][4] * 0.185  , aObjSize[1][3], aObjSize[1][4] * 0.87, TitSX3("RA_NOME")[1]   ,,, .T.) // "Nome:"
oGroupAdi  := TGroup():Create( oDlgPai, aObjSize[1][1], aObjSize[1][4] * 0.875  , aObjSize[1][3], aObjSize[1][4]       , TitSX3("RA_ADMISSA")[1],,, .T.) // "Admiss�o:"

oGroupMat:oFont  := oFont 
oGroupNome:oFont := oFont
oGroupAdi:oFont  := oFont

oSayMat   := TSay():Create(oDlgPai , {|| Dtoc(TRB->RA_ADMISSA)}	, aObjSize[1][1] + 10, aObjSize[1][4] * 0.89,, oFont,,,, .T.,,, 050, 010)
oSayNome  := TSay():Create(oDlgPai , {|| TRB->RA_MAT}				, aObjSize[1][1] + 10, aObjSize[1][2] * 2.50,, oFont,,,, .T.,,, 050, 010)
oSayAdi   := TSay():Create(oDlgPai , {|| If(lOfuscaNom,Replicate('*',15),OemToAnsi(TRB->RA_NOME))}	, aObjSize[1][1] + 10, aObjSize[1][4] * 0.20,, oFont,,,, .T.,,, 146, 010)
Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CarPanel1  � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function CarPanel1(aObj2Size, cAlias, nReg, nOpcX)
Local nTop      := aObj2Size[1,1]
Local nLeft     := aObj2Size[1,2]
Local nWidth    := aObj2Size[1,3]
Local nHeight   := aObj2Size[1,4]
Local nModelo	:= 3	//Enchoice
Local lF3		:= .F.	//Enchoice
Local lMemoria	:= .T.	//Enchoice
Local lColumn	:= .F.	//Enchoice            	                                                   
Local caTela	:= ""	//Enchoice
Local lNoFolder	:= .F.	//Enchoice
Local lProperty	:= .F. 	//Enchoice

//�������������������������������������������������Ŀ
//� Seta painel na aba 1                            |
//���������������������������������������������������
oPanel1 := TPanel():New(nTop, nLeft, '', oFolder:aDialogs[1],, .T., .T.,,, nWidth, nHeight,.F.,.F. )

//�������������������������������������������������Ŀ
//� Carrega para memoria varievais dos campos RGW   |
//���������������������������������������������������
aCpoRGW1 := {"RGW_FILIAL","RGW_MAT","RGW_HOMOL","RGW_TPRESC","RGW_JTCUMP","RGW_COMPSA","RGW_FM13","RGW_PER13","RGW_QTDE13",;
  			 "RGW_MA13","RGW_FMFER","RGW_PERFER","RGW_QTDFER","RGW_MAFER","RGW_FMAV","RGW_QTDEAV","RGW_MAAV","RGW_DAVISO","RGW_NUMID","RGW_CCUSTO"}

//�������������������������������������������������Ŀ
//� Seta enchoice dentro do painel 1                |
//���������������������������������������������������  					 
oEnch1	 := MsMGet():New('RGW', nReg, 2, , ,, aCpoRGW1, {nTop, nLeft, nHeight-15, nWidth-3}, aCpoRGW1, nModelo,,,, oPanel1, lF3, lMemoria, lColumn, caTela, lNoFolder, lProperty)
//�����������������������������������������������������������������������������������������Ŀ
//� Este metodo desabilita a edicao de todos os controles do folder do objeto MsMGet ativo. �
//�������������������������������������������������������������������������������������������  					 
oEnch1:Disable()

//�����������������������������������������������������������������������Ŀ
//� Array com campos que podem ser alterados                              �
//�������������������������������������������������������������������������
aAltRGW1 := aClone(aCpoRGW1)

//�����������������������������������������������������������������������Ŀ
//� Array com dados da tela de alteracao de dados ferias e 13o            �
//�������������������������������������������������������������������������
aAdd(aPadraoRGW,{"RGW_FILIAL", TRB->RA_FILIAL 					})
aAdd(aPadraoRGW,{"RGW_MAT"	 , RGW->RGW_MAT   					})
aAdd(aPadraoRGW,{"RGW_HOMOL" , RGW->RGW_HOMOL 					})
aAdd(aPadraoRGW,{"RGW_TPRESC", RGW->RGW_TPRESC					})
aAdd(aPadraoRGW,{"RGW_JTCUMP", RGW->RGW_JTCUMP					})
aAdd(aPadraoRGW,{"RGW_COMPSA", RGW->RGW_COMPSA					})
aAdd(aPadraoRGW,{"RGW_FM13"  , RGW->RGW_FM13  					})
aAdd(aPadraoRGW,{"RGW_PER13" , RGW->RGW_PER13 					})
aAdd(aPadraoRGW,{"RGW_QTDE13", RGW->RGW_QTDE13					})
aAdd(aPadraoRGW,{"RGW_MA13"  , RGW->RGW_MA13  					})
aAdd(aPadraoRGW,{"RGW_FMFER" , RGW->RGW_FMFER 					})
aAdd(aPadraoRGW,{"RGW_PERFER", RGW->RGW_PERFER					})
aAdd(aPadraoRGW,{"RGW_QTDFER", RGW->RGW_QTDFER					})
aAdd(aPadraoRGW,{"RGW_MAFER" , RGW->RGW_MAFER 					})
aAdd(aPadraoRGW,{"RGW_FMAV"  , RGW->RGW_FMAV  					})
aAdd(aPadraoRGW,{"RGW_QTDEAV", RGW->RGW_QTDEAV					})
aAdd(aPadraoRGW,{"RGW_MAAV"  , RGW->RGW_MAAV  					})
aAdd(aPadraoRGW,{"RGW_DAVISO", RGW->RGW_DAVISO					})
aAdd(aPadraoRGW,{"RGW_NUMID" , RGW->RGW_NUMID 					})
aAdd(aPadraoRGW,{"RGW_CCUSTO", RGW->RGW_CCUSTO					})

//�����������������������������������������������������������������������Ŀ
//� O primeiro painel com os dados do funcionario nao podem ser alterados �
//�������������������������������������������������������������������������
oPanel1:lReadOnly := .T.

Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CarPanel2  � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function CarPanel2(aObj3Size, cAlias, nReg, nOpcX)
Local nTop     := aObj3Size[1,1]
Local nLeft    := aObj3Size[1,2]
Local nWidth   := aObj3Size[1,3]
Local nHeightP := aObj3Size[2,4]
Local nHeightG := aObj3Size[1,4]

//�������������������������������������������������Ŀ
//� Seta painel na aba 2                            |
//���������������������������������������������������
oPanel2 := TPanel():New(nTop, nLeft, '', oFolder:aDialogs[2],, .T., .T.,,, nWidth, nHeightP, .F., .F. )

//�������������������������������������������������Ŀ
//� Seta grid no painel 2                           |
//���������������������������������������������������
oBrowRGW2 := BrGetDDB():New(nTop, nLeft, nWidth-5, nHeightG,,,, oPanel2,,,,,,,,,,,, .F., 'RGW', .T.,, .F.)
oBrowRGW2:bDelOk	:= {||.T.}

//�����������������������������������������������������Ŀ
//� Atribui os campos a tabela da aba - Dados de ferias �
//�������������������������������������������������������	
oBrowRGW2:AddColumn(TCColumn():New(TitSX3("RGW_DTINI" )[1]		, {||RGW->RGW_DTINI}	,PESQPICT("RGW","RGW_DTINI"		),,,'LEFT' ,TAMSX3("RGW_DTINI"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW2:AddColumn(TCColumn():New(TitSX3("RGW_DTFIM" )[1]		, {||RGW->RGW_DTFIM}	,PESQPICT("RGW","RGW_DTFIM"		),,,'LEFT' ,TAMSX3("RGW_DTFIM"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW2:AddColumn(TCColumn():New(TitSX3("RGW_QUIT"  )[1]		, {||RGW->RGW_QUIT}		,PESQPICT("RGW","RGW_QUIT" 		),,,'LEFT' ,TAMSX3("RGW_QUIT"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW2:AddColumn(TCColumn():New(TitSX3("RGW_FALT"  )[1]		, {||RGW->RGW_FALT}		,PESQPICT("RGW","RGW_FALT" 		),,,'RIGHT',TAMSX3("RGW_FALT"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW2:AddColumn(TCColumn():New(TitSX3("RGW_ALT"   )[1]		, {||RGW->RGW_ALT}		,PESQPICT("RGW","RGW_ALT"  		),,,'RIGHT',TAMSX3("RGW_ALT"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW2:AddColumn(TCColumn():New(""							, 						,								 ,,,'LEFT',							,.F.,.F.,,,,.F.,))

//�������������������������������������������������Ŀ
//� Carrega para memoria varievais dos campos RGW   |
//���������������������������������������������������      
aCpoRGW2 := {"RGW_TPREG","RGW_DTINI","RGW_DTFIM","RGW_QUIT","RGW_FALT","RGW_ALT"}

//�����������������������������������������������������������������������Ŀ
//� Array com campos que podem ser alterados                              �
//�������������������������������������������������������������������������
aAltRGW2 := {"RGW_DTINI" , "RGW_DTFIM" , "RGW_QUIT"  , "RGW_FALT"  }

//�����������������������������������������������������������������������Ŀ
//� Oculta os painel                                                      �
//�������������������������������������������������������������������������
oPanel2:Hide()

//�����������������������������������������������������������������������Ŀ
//� Botao incluir                                                         �
//�������������������������������������������������������������������������
oSButInc2 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+10,04, {||GPEM601UPD(2, nReg, nOpcX, .T., .F.)}, oPanel2, .T., STR0010+" "+STR0004 )//"Incluir dados de F�rias"

//�����������������������������������������������������������������������Ŀ
//� Botao alterar                                                         �
//�������������������������������������������������������������������������
oSButAlt2 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+50,11, {||GPEM601UPD(2, nReg, nOpcX, .F., .F.)}, oPanel2, .T., STR0011+" "+STR0004, {||If(!RGW->(EoF()) .And. !RGW->(BoF()), .T., .F.)})//"Editar dados de F�rias"

//�����������������������������������������������������������������������Ŀ
//� Botao delecao                                                         �
//�������������������������������������������������������������������������
oSButDel2 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+90,03, {||GPEM601Del(2, nReg, nOpcX, .F., .F.)}, oPanel2, .T., STR0012+" "+STR0004, {||If(!RGW->(EoF()) .And. !RGW->(BoF()), .T., .F.)})//"Excluir dados de F�rias"

Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CarPanel3  � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function CarPanel3(aObj3Size, cAlias, nReg, nOpcX)
Local nTop     := aObj3Size[1,1]
Local nLeft    := aObj3Size[1,2]
Local nWidth   := aObj3Size[1,3]
Local nHeightP := aObj3Size[2,4]
Local nHeightG := aObj3Size[1,4]

//�������������������������������������������������Ŀ
//� Seta painel na aba 3                            |
//���������������������������������������������������
oPanel3 := TPanel():New(nTop, nLeft, '', oFolder:aDialogs[3],, .T., .T.,,,nWidth, nHeightP, .F., .F. )

//�������������������������������������������������Ŀ
//� Seta grid no painel 3                           |
//���������������������������������������������������
oBrowRGW3 := BrGetDDB():New(nTop, nLeft, nWidth-5, nHeightG,,,, oPanel3,,,,,,,,,,,, .F., 'RGW', .T.,, .F.)
oBrowRGW3:bDelOk	:= {||.T.}

//�����������������������������������������������������Ŀ
//� Atribui os campos a tabela da aba - Dados de 13o    �
//�������������������������������������������������������	
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_DTINI" )[1]+"   ", {||RGW->RGW_DTINI}	,PESQPICT("RGW","RGW_DTINI"		),,,'LEFT' ,TAMSX3("RGW_DTINI"  )[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_QUIT"  )[1]+"   ", {||RGW->RGW_QUIT}		,PESQPICT("RGW","RGW_QUIT"		),,,'LEFT' ,TAMSX3("RGW_QUIT"   )[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_VALP13")[1]+"   ", {||RGW->RGW_VALP13}	,PESQPICT("RGW","RGW_VALP13"	),,,'RIGHT',TAMSX3("RGW_VALP13"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M01"   )[1]+"   ", {||RGW->RGW_M01}		,PESQPICT("RGW","RGW_M01"		),,,'RIGHT',TAMSX3("RGW_M01"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M02"   )[1]+"   ", {||RGW->RGW_M02}		,PESQPICT("RGW","RGW_M02"		),,,'RIGHT',TAMSX3("RGW_M02"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M03"   )[1]+"   ", {||RGW->RGW_M03}		,PESQPICT("RGW","RGW_M03"		),,,'RIGHT',TAMSX3("RGW_M03"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M04"   )[1]+"   ", {||RGW->RGW_M04}		,PESQPICT("RGW","RGW_M04"		),,,'RIGHT',TAMSX3("RGW_M04"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M05"   )[1]+"   ", {||RGW->RGW_M05}		,PESQPICT("RGW","RGW_M05"		),,,'RIGHT',TAMSX3("RGW_M05"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M06"   )[1]+"   ", {||RGW->RGW_M06}		,PESQPICT("RGW","RGW_M06"		),,,'RIGHT',TAMSX3("RGW_M06"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M07"   )[1]+"   ", {||RGW->RGW_M07}		,PESQPICT("RGW","RGW_M07"		),,,'RIGHT',TAMSX3("RGW_M07"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M08"   )[1]+"   ", {||RGW->RGW_M08}		,PESQPICT("RGW","RGW_M08"		),,,'RIGHT',TAMSX3("RGW_M08"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M09"   )[1]+"   ", {||RGW->RGW_M09}		,PESQPICT("RGW","RGW_M09"		),,,'RIGHT',TAMSX3("RGW_M09"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M10"   )[1]+"   ", {||RGW->RGW_M10}		,PESQPICT("RGW","RGW_M10"		),,,'RIGHT',TAMSX3("RGW_M10"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M11"   )[1]+"   ", {||RGW->RGW_M11}		,PESQPICT("RGW","RGW_M11"		),,,'RIGHT',TAMSX3("RGW_M11"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_M12"   )[1]+"   ", {||RGW->RGW_M12}		,PESQPICT("RGW","RGW_M12"		),,,'RIGHT',TAMSX3("RGW_M12"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(TitSX3("RGW_ALT"   )[1]+"   ", {||RGW->RGW_ALT}		,PESQPICT("RGW","RGW_ALT"		),,,'RIGHT',TAMSX3("RGW_ALT"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW3:AddColumn(TCColumn():New(""							, 						,								 ,,,'RIGHT',						,.F.,.F.,,,,.F.,))

//�������������������������������������������������Ŀ
//� Carrega para memoria varievais dos campos RGW   |
//���������������������������������������������������            
aCpoRGW3 := {	"RGW_TPREG","RGW_DTINI","RGW_QUIT","RGW_VALP13","RGW_M01","RGW_M02","RGW_M03",;
				"RGW_M04","RGW_M05","RGW_M06","RGW_M07","RGW_M08","RGW_M09","RGW_M10","RGW_M11","RGW_M12","RGW_ALT"}

//�����������������������������������������������������������������������Ŀ
//� Array com campos que podem ser alterados                              �
//�������������������������������������������������������������������������
aAltRGW3 := {"RGW_DTINI" , "RGW_QUIT"  , "RGW_VALP13", "RGW_M01"  , "RGW_M02"   , "RGW_M03"   , "RGW_M04" , "RGW_M05"  , "RGW_M06"   , "RGW_M07" , "RGW_M08"   , "RGW_M09"   , "RGW_M10"   , "RGW_M11"  , "RGW_M12"   }							

//�����������������������������������������������������������������������Ŀ
//� Oculta os painel                                                      �
//�������������������������������������������������������������������������
oPanel3:Hide()

//�����������������������������������������������������������������������Ŀ
//� Botao incluir                                                         �
//�������������������������������������������������������������������������
oSButInc3 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+10,04, {||GPEM601UPD(3, nReg, nOpcX, .T., .F.)}, oPanel3, .T., STR0010+" "+STR0005 )//"Incluir dados de 13�"

//�����������������������������������������������������������������������Ŀ
//� Botao alterar                                                         �
//�������������������������������������������������������������������������
oSButAlt3 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+50,11, {||GPEM601UPD(3, nReg, nOpcX, .F., .F.)}, oPanel3, .T., STR0011+" "+STR0005, {||If(!RGW->(EoF()) .And. !RGW->(BoF()), .T., .F.)})//"Editar dados de 13�"

//�����������������������������������������������������������������������Ŀ
//� Botao delecao                                                         �
//�������������������������������������������������������������������������
oSButDel3 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+90,03, {||GPEM601Del(3, nReg, nOpcX, .F., .F.)}, oPanel3, .T., STR0012+" "+STR0005, {||If(!RGW->(EoF()) .And. !RGW->(BoF()), .T., .F.)})//"Excluir dados de 13�"

Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CarPanel4  � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function CarPanel4(aObj3Size, cAlias, nReg, nOpcX)

//�������������������������������������������������Ŀ
//� Seta painel na aba 4                            |
//���������������������������������������������������
oPanel4 	:= TPanel():New(aObj3Size[1,1], aObj3Size[1,2],'',oFolder:aDialogs[4],, .T., .T.,, ,aObj3Size[1,3], aObj3Size[2,4],.F.,.F. )

//�������������������������������������������������Ŀ
//� Seta grid no painel 4                           |
//���������������������������������������������������
oBrowRGX	:= BrGetDDB():New(aObj3Size[1,1],aObj3Size[1,2],aObj3Size[1,3]-5,aObj3Size[1,4],,,,oPanel4,,,,,,,,,,,,.F.,'RGX',.T.,,.F.,,, )
oBrowRGX:bDelOk		:= {||.T.}

//������������������������������������������������������Ŀ
//� Atribui os campos a tabela da aba - Dados financeiros�
//��������������������������������������������������������	
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_TPREG" )[1]+"   ",{||RGX->RGX_TPREG} 		,PESQPICT("RGX","RGX_TPREG"		),,,'LEFT' ,TAMSX3("RGX_TPREG"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_MESANO")[1]+"   ",{||RGX->RGX_MESANO}		,PESQPICT("RGX","RGX_MESANO"	),,,'LEFT' ,TAMSX3("RGX_MESANO"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_FORSAL")[1]+"   ",{||RGX->RGX_FORSAL}		,PESQPICT("RGX","RGX_FORSAL"	),,,'LEFT' ,TAMSX3("RGX_FORSAL"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_TPSAL" )[1]+"   ",{||RGX->RGX_TPSAL}		,PESQPICT("RGX","RGX_TPSAL"		),,,'LEFT' ,TAMSX3("RGX_TPSAL"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_CODRUB")[1]+"   ",{||RGX->RGX_CODRUB}		,PESQPICT("RGX","RGX_CODRUB"	),,,'LEFT' ,TAMSX3("RGX_CODRUB"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_VALRUB")[1]+"   ",{||RGX->RGX_VALRUB}		,PESQPICT("RGX","RGX_VALRUB"	),,,'RIGHT',TAMSX3("RGX_VALRUB"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_PROD"  )[1]+"   ",{||RGX->RGX_PROD}		,PESQPICT("RGX","RGX_PROD"		),,,'LEFT' ,TAMSX3("RGX_PROD"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_VALBC" )[1]+"   ",{||RGX->RGX_VALBC}		,PESQPICT("RGX","RGX_VALBC"		),,,'RIGHT',TAMSX3("RGX_VALBC"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_QTDPRO")[1]+"   ",{||RGX->RGX_QTDPRO}		,PESQPICT("RGX","RGX_QTDPRO"	),,,'RIGHT',TAMSX3("RGX_QTDPRO"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_PERC"  )[1]+"   ",{||RGX->RGX_PERC}		,PESQPICT("RGX","RGX_PERC"		),,,'RIGHT',TAMSX3("RGX_PERC"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_QTDHOR")[1]+"   ",{||RGX->RGX_QTDHOR}		,PESQPICT("RGX","RGX_QTDHOR"	),,,'RIGHT',TAMSX3("RGX_QTDHOR"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_SALLIQ")[1]+"   ",{||RGX->RGX_SALLIQ}		,PESQPICT("RGX","RGX_SALLIQ"	),,,'RIGHT',TAMSX3("RGX_SALLIQ"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_TRIBUT")[1]+"   ",{||RGX->RGX_TRIBUT}		,PESQPICT("RGX","RGX_TRIBUT"	),,,'LEFT' ,TAMSX3("RGX_TRIBUT"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_INTBC" )[1]+"   ",{||RGX->RGX_INTBC}		,PESQPICT("RGX","RGX_INTBC"		),,,'LEFT' ,TAMSX3("RGX_INTBC"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_QTDDSR")[1]+"   ",{||RGX->RGX_QTDDSR}		,PESQPICT("RGX","RGX_QTDDSR"	),,,'LEFT' ,TAMSX3("RGX_QTDDSR"	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(TitSX3("RGX_ALT"   )[1]+"   ",{||RGX->RGX_ALT   }		,PESQPICT("RGX","RGX_ALT"   	),,,'LEFT' ,TAMSX3("RGX_ALT"   	)[1],.F.,.F.,,,,.F.,))
oBrowRGX:AddColumn(TCColumn():New(""						   ,						,								 ,,,'RIGHT',						,.F.,.F.,,,,.F.,))

//�������������������������������������������������Ŀ
//� Carrega para memoria varievais dos campos RGX   |
//���������������������������������������������������      
CarCampos("RGX", @aCpoRGX)

//�����������������������������������������������������������������������Ŀ
//� Array com dados da tela de alteracao de dados financeiro              �
//�������������������������������������������������������������������������
aAdd(aPadraoRGX,{"RGX_FILIAL", xFilial("RGX",TRB->RA_FILIAL) 	})
aAdd(aPadraoRGX,{"RGX_MAT"	 , TRB->RA_MAT    					})
aAdd(aPadraoRGX,{"RGX_HOMOL" , TRB->RG_DATAHOM					})
aAdd(aPadraoRGX,{"RGX_TPRESC", "1"            					})//Tipo de Rescis�o
aAdd(aPadraoRGX,{"RGX_ALT"	 , RGX->RGX_ALT						})

//�����������������������������������������������������������������������Ŀ
//� Array com campos que podem ser alterados                              �
//�������������������������������������������������������������������������
aAltRGX :={"RGX_TPREG","RGX_MESANO","RGX_FORSAL","RGX_TPSAL", "RGX_CODRUB","RGX_VALRUB","RGX_PROD",  "RGX_VALBC", "RGX_QTDPRO","RGX_PERC",  "RGX_QTDHOR","RGX_SALLIQ","RGX_TRIBUT","RGX_INTBC", "RGX_QTDDSR"}

//�����������������������������������������������������������������������Ŀ
//� Oculta os painel                                                      �
//�������������������������������������������������������������������������
oPanel4:Hide()

//�����������������������������������������������������������������������Ŀ
//� Botao incluir                                                         �
//�������������������������������������������������������������������������
oSButInc4 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+10,04, {||GPEM601UPD(4, nReg, nOpcX, .T., .F.)}, oPanel4, .T., STR0010+" "+STR0006 )//"Incluir dados Financeiros"

//�����������������������������������������������������������������������Ŀ
//� Botao alterar                                                         �
//�������������������������������������������������������������������������
oSButAlt4 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+50,11, {||GPEM601UPD(4, nReg, nOpcX, .F., .F.)}, oPanel4, .T., STR0011+" "+STR0006, {||If(!RGX->(EoF()) .And. !RGX->(BoF()), .T., .F.)})//"Editar dados Financeiros"

//�����������������������������������������������������������������������Ŀ
//� Botao delecao                                                         �
//�������������������������������������������������������������������������
oSButDel4 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+90,03, {||GPEM601Del(4, nReg, nOpcX, .F., .F.)}, oPanel4, .T., STR0012+" "+STR0005, {||If(!RGX->(EoF()) .And. !RGX->(BoF()), .T., .F.)})//"Excluir dados Financeiros"

Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CarPanel5  � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function CarPanel5(aObj3Size, cAlias, nReg, nOpcX)
Local nTop     := aObj3Size[1,1]
Local nLeft    := aObj3Size[1,2]
Local nWidth   := aObj3Size[1,3]
Local nHeightP := aObj3Size[2,4]
Local nHeightG := aObj3Size[1,4]

//�������������������������������������������������Ŀ
//� Seta painel na aba 5                            |
//���������������������������������������������������
oPanel5 := TPanel():New(nTop, nLeft,'',oFolder:aDialogs[5],, .T., .T.,,, nWidth, nHeightP, .F., .F. )

//�������������������������������������������������Ŀ
//� Seta grid no painel 5                           |
//���������������������������������������������������
oBrowRGZ := BrGetDDB():New(nTop, nLeft, nWidth-5, nHeightG,,,, oPanel5,,,,,,,,,,,, .F., 'RGZ', .T.,, .F.)
oBrowRGZ:bDelOk		:= {||.T.}

//�����������������������������������������������������Ŀ
//� Atribui os campos a tabela da aba - Movimentacoes   �
//�������������������������������������������������������	
oBrowRGZ:AddColumn(TCColumn():New(TitSX3("RGZ_DTMVTO")[1]+"   ",{||RGZ->RGZ_DTMVTO}		,PESQPICT("RGZ","RGZ_DTMVTO"	),,,'LEFT' ,TAMSX3("RGZ_DTMVTO"	)[1],.F.,.F.,,,,.F.,))
oBrowRGZ:AddColumn(TCColumn():New(TitSX3("RGZ_MOTIVO")[1]+"   ",{||RGZ->RGZ_MOTIVO}		,PESQPICT("RGZ","RGZ_MOTIVO"	),,,'LEFT' ,TAMSX3("RGZ_MOTIVO"	)[1],.F.,.F.,,,,.F.,))
oBrowRGZ:AddColumn(TCColumn():New(TitSX3("RGZ_ALT"   )[1]+"   ",{||RGZ->RGZ_ALT   }		,PESQPICT("RGZ","RGZ_ALT"   	),,,'LEFT' ,TAMSX3("RGZ_ALT"   	)[1],.F.,.F.,,,,.F.,))
oBrowRGZ:AddColumn(TCColumn():New(""						   ,						,								 ,,,'LEFT' ,						,.F.,.F.,,,,.F.,))

//�������������������������������������������������Ŀ
//� Carrega para memoria varievais dos campos RGZ   |
//���������������������������������������������������      
CarCampos("RGZ", @aCpoRGZ)

//�����������������������������������������������������������������������Ŀ
//� Array com campos que podem ser alterados                              �
//�������������������������������������������������������������������������
aAltRGZ :={"RGZ_MOTIVO","RGZ_DTMVTO"}

//�����������������������������������������������������������������������Ŀ
//� Array com dados da tela de alteracao de movimentacao                  �
//�������������������������������������������������������������������������
aAdd(aPadraoRGZ,{"RGZ_FILIAL", xFilial("RGZ",TRB->RA_FILIAL) 	})
aAdd(aPadraoRGZ,{"RGZ_MAT"	 , TRB->RA_MAT    					})
aAdd(aPadraoRGZ,{"RGZ_HOMOL" , TRB->RG_DATAHOM					})
aAdd(aPadraoRGZ,{"RGZ_TPRESC", "1"            					})//Tipo de Rescis�o
aAdd(aPadraoRGZ,{"RGZ_ALT"	 , RGZ->RGZ_ALT						})

//�����������������������������������������������������������������������Ŀ
//� Oculta os painel                                                      �
//�������������������������������������������������������������������������
oPanel5:Hide()

//�����������������������������������������������������������������������Ŀ
//� Botao incluir                                                         �
//�������������������������������������������������������������������������
oSButInc5 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+10,04, {||GPEM601UPD(5, nReg, nOpcX, .T., .F.)}, oPanel5, .T., STR0010+" "+STR0007 )//"Incluir Movimenta��es"

//�����������������������������������������������������������������������Ŀ
//� Botao alterar                                                         �
//�������������������������������������������������������������������������
oSButAlt5 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+50,11, {||GPEM601UPD(5, nReg, nOpcX, .F., .F.)}, oPanel5, .T., STR0011+" "+STR0007, {||If(!RGZ->(EoF()) .And. !RGZ->(BoF()), .T., .F.)})//"Editar Movimenta��es"

//�����������������������������������������������������������������������Ŀ
//� Botao delecao                                                         �
//�������������������������������������������������������������������������
oSButDel5 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+90,03, {||GPEM601Del(5, nReg, nOpcX, .F., .F.)}, oPanel5, .T., STR0012+" "+STR0006, {||If(!RGZ->(EoF()) .And. !RGZ->(BoF()), .T., .F.)})//"Excluir Movimenta��es"

Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CarPanel6  � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function CarPanel6(aObj3Size, cAlias, nReg, nOpcX)
Local nTop     := aObj3Size[1,1]
Local nLeft    := aObj3Size[1,2]
Local nWidth   := aObj3Size[1,3]
Local nHeightP := aObj3Size[2,4]
Local nHeightG := aObj3Size[1,4]

//�������������������������������������������������Ŀ
//� Seta painel na aba 6                            |
//���������������������������������������������������
oPanel6 := TPanel():New(nTop, nLeft, '', oFolder:aDialogs[6],, .T., .T.,,, nWidth, nHeightP,.F.,.F. )

//�������������������������������������������������Ŀ
//� Seta grid no painel 6                           |
//���������������������������������������������������
oBrowRGY := BrGetDDB():New(nTop, nLeft, nWidth-5, nHeightG,,,, oPanel6,,,,,,,,,,,, .F., 'RGY', .T.,, .F. )           
oBrowRGY:bDelOk	:= {||.T.}	

//�����������������������������������������������������������������Ŀ
//� Atribui os campos a tabela da aba - Dados descontos da Rescisao �
//�������������������������������������������������������������������	
oBrowRGY:AddColumn(TCColumn():New(TitSX3("RGY_TPREG" )[1]+"   ",{||RGY->RGY_TPREG}		,PESQPICT("RGY","RGY_TPREG"		),,,'LEFT' ,TAMSX3("RGY_TPREG"	)[1],.F.,.F.,,,,.F.,))
oBrowRGY:AddColumn(TCColumn():New(TitSX3("RGY_CODIGO")[1]+"   ",{||RGY->RGY_CODIGO}		,PESQPICT("RGY","RGY_CODIGO"	),,,'LEFT' ,TAMSX3("RGY_CODIGO"	)[1],.F.,.F.,,,,.F.,))
oBrowRGY:AddColumn(TCColumn():New(TitSX3("RGY_VALHOR")[1]+"   ",{||RGY->RGY_VALHOR}		,PESQPICT("RGY","RGY_VALHOR"	),,,'RIGHT',TAMSX3("RGY_VALHOR"	)[1],.F.,.F.,,,,.F.,))
oBrowRGY:AddColumn(TCColumn():New(TitSX3("RGY_TRIBUT")[1]+"   ",{||RGY->RGY_TRIBUT}		,PESQPICT("RGY","RGY_TRIBUT"	),,,'LEFT' ,TAMSX3("RGY_TRIBUT"	)[1],.F.,.F.,,,,.F.,))
oBrowRGY:AddColumn(TCColumn():New(TitSX3("RGY_ALT"   )[1]+"   ",{||RGY->RGY_ALT   }		,PESQPICT("RGY","RGY_ALT"   	),,,'LEFT' ,TAMSX3("RGY_ALT"   	)[1],.F.,.F.,,,,.F.,))
oBrowRGY:AddColumn(TCColumn():New(""						   ,						,								 ,,,'LEFT' ,						,.F.,.F.,,,,.F.,))

//�������������������������������������������������Ŀ
//� Carrega para memoria varievais dos campos RGY   |
//���������������������������������������������������      
CarCampos("RGY", @aCpoRGY)

//�����������������������������������������������������������������������Ŀ
//� Array com campos que podem ser alterados                              �
//�������������������������������������������������������������������������
aAltRGY :={"RGY_TPREG","RGY_CODIGO","RGY_VALHOR","RGY_TRIBUT"}

//�����������������������������������������������������������������������Ŀ
//� Array com dados da tela de alteracao de rescisao                      �
//�������������������������������������������������������������������������
aAdd(aPadraoRGY,{"RGY_FILIAL", xFilial("RGY",TRB->RA_FILIAL) 	})
aAdd(aPadraoRGY,{"RGY_MAT"	 , TRB->RA_MAT    					})
aAdd(aPadraoRGY,{"RGY_HOMOL" , TRB->RG_DATAHOM					})
aAdd(aPadraoRGY,{"RGY_TPRESC", "1"            					})//Tipo de Rescis�o
aAdd(aPadraoRGY,{"RGY_ALT"	 , RGY->RGY_ALT						})

//�����������������������������������������������������������������������Ŀ
//� Oculta os painel                                                      �
//�������������������������������������������������������������������������
oPanel6:Hide()

//�����������������������������������������������������������������������Ŀ
//� Botao incluir                                                         �
//�������������������������������������������������������������������������
oSButInc6 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+10,04, {||GPEM601UPD(6, nReg, nOpcX, .T., .F.)}, oPanel6, .T., STR0010+" "+STR0008 )//"Incluir descontos da Rescis�o"

//�����������������������������������������������������������������������Ŀ
//� Botao alterar                                                         �
//�������������������������������������������������������������������������
oSButAlt6 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+50,11, {||GPEM601UPD(6, nReg, nOpcX, .F., .F.)}, oPanel6, .T., STR0011+" "+STR0008, {||If(!RGY->(EoF()) .And. !RGY->(BoF()), .T., .F.)})//"Editar descontos da Rescis�o"

//�����������������������������������������������������������������������Ŀ
//� Botao delecao                                                         �
//�������������������������������������������������������������������������
oSButDel6 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+90,03, {||GPEM601Del(6, nReg, nOpcX, .F., .F.)}, oPanel6, .T., STR0012+" "+STR0007, {||If(!RGY->(EoF()) .And. !RGY->(BoF()), .T., .F.)})//"Excluir descontos da Rescis�o"

Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CarCampos  � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function CarCampos(cAliasCar, aArrAlias)
dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek(cAliasCar))
While !Eof() .And. SX3->X3_ARQUIVO == cAliasCar
	If !("FILIAL" $ SX3->X3_CAMPO) .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
	   	aAdd(aArrAlias, SX3->X3_CAMPO) 
	EndIf
	SX3->(dbSkip())
End

Return()

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601TOK � Autor � Wagner Montenegro  � Data � 30/10/2010 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o de Valida��o da Enchoice Homolognet		  		   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601TOK()                                                ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  												       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function GPEM601TOK(nFolder,lNovo)
Local lRet		:= .T.
Local aTOkCpos	:= {}
Local cRetMens	:= ""
Local nX		:= 0
Local nRegRGW	:= 0
Local nRegRGY	:= 0
Local nRegRGZ	:= 0
Local nRegRGX	:= 0

If nFolder == 2
	//�����������������������������������������������������Ŀ
	//� Valida item de ferias - aba 2                       �
	//�������������������������������������������������������	
	nRegRGW:=RGW->(Recno())
	If RGW->(dbSeek(xFilial("RGW",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+"1"+DtoS(M->RGW_DTINI)))
		If !lNovo .AND. RGW->(Recno())<>nRegRGW .or. lNovo
			lRet:=.F.
			MsgAlert(STR0013)//"Periodo aquisitivo j� cadastrado!"
		EndIf	
	EndIf
	RGW->(dbGoTo(nRegRGW))
	If lRet
		oDlgAlter:End()
	EndIf	
ElseIf nFolder == 3
	//�����������������������������������������������������Ŀ
	//� Valida item de 13o - aba 3                          �
	//�������������������������������������������������������	
	nRegRGW:=RGW->(Recno())
	If RGW->(dbSeek(xFilial("RGW",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+"2"+DtoS(M->RGW_DTINI))) 
		If !lNovo .AND. RGW->(Recno())<>nRegRGW .or. lNovo
			lRet:=.F.
			MsgAlert(STR0014)//"Exercicio j� cadastrado!"
		EndIf
	EndIf
	RGW->(dbGoTo(nRegRGW))
	If lRet
		oDlgAlter:End()
	EndIf	
ElseIf nFolder == 4
	//�����������������������������������������������������Ŀ
	//� Valida item de dados financeiro - aba 4             �
	//�������������������������������������������������������	
	If Empty(M->RGX_PROD) .AND. M->RGX_CODRUB='003'
		lRet:=.F.
	  	aAdd(aTOkCpos,{TitSX3("RGX_PROD"  )[1]})
	EndIf
	If M->RGX_VALBC==0 .AND. M->RGX_CODRUB$'003/013/014/018/019'
		lRet:=.F.
	  	aAdd(aTOkCpos,{TitSX3("RGX_VALBC" )[1]})
	EndIf
	If M->RGX_QTDPRO==0 .AND. M->RGX_CODRUB=='003'
		lRet:=.F.
	  	aAdd(aTOkCpos,{TitSX3("RGX_QTDPRO")[1]})
	EndIf
	If M->RGX_PERC==0 .AND. M->RGX_CODRUB$'004/012/013/014/018/019'
		lRet:=.F.
	  	aAdd(aTOkCpos,{TitSX3("RGX_PERC"  )[1]})
	EndIf 
	If M->RGX_QTDHOR==0 .AND. M->RGX_TPREG=='1' .AND. M->RGX_CODRUB $ '004/012/015/016/035' .or. M->RGX_QTDHOR==0 .AND. M->RGX_TPREG=='1' .AND. M->RGX_CODRUB=='005' .AND. M->RGX_TPSAL=='1'
		lRet:=.F.
		aAdd(aTOkCpos,{TitSX3("RGX_QTDHOR")[1]})
	EndIf
	If M->RGX_QTDDSR==0 .AND. M->RGX_MESANO=="999999"                          
		lRet:=.F.
	  	aAdd(aTOkCpos,{TitSX3("RGX_QTDDSR")[1]})
	EndIf
	If EMPTY(M->RGX_TPSAL) .AND. M->RGX_FORSAL$'1/3'
		lRet:=.F.
	  	aAdd(aTOkCpos,{TitSX3("RGX_TPSAL" )[1]})
	EndIf	
	If !lRet
		For nX:=1 To Len(aTOkCpos)
			cRetMens+="'"+aTOkCpos[nX,1]+"'"
			If Len(aTOkCpos)>nX 	.And. Len(aTOkCpos)>(nX+1)
				cRetMens+=", "
			ElseIf Len(aTOkCpos)>1 	.And. Len(aTOkCpos)==(nX+1)
				cRetMens+=" e "
			EndIf
	   	Next
	   	cRetMens+="' "
	   	If Len(aTOkCpos)>1
	   		MsgAlert(STR0015+cRetMens+STR0016)//"Os campos: " //" s�o de preenchimento obrigat�rio!"
		Else 
			MsgAlert(STR0017+cRetMens+STR0018)//"O campo " //" � de preenchimento obrigat�rio!"
		Endif
	Else
		nRegRGX:=RGX->(Recno())
		If RGX->(dbSeek(xFilial("RGX",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+M->RGX_MESANO+M->RGX_TPREG+M->RGX_CODRUB)) 
			If !lNovo .and.  RGX->(Recno())<>nRegRGX .or. lNovo
				lRet:=.F.
				MsgAlert(STR0019)//"O Tipo e C�digo de Rubrica informados para o per�odo j� existe na base de dados!"
			EndIf
		EndIf
		RGX->(dbGoTo(nRegRGX))
		If lRet
			oDlgAlter:End()
		EndIf
	Endif
ElseIf nFolder == 5
	//�����������������������������������������������������Ŀ
	//� Valida item de movimentacao - aba 5                 �
	//�������������������������������������������������������	
	nRegRGZ:=RGZ->(Recno())
	If RGZ->(dbSeek(xFilial("RGZ",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+M->RGZ_MOTIVO+DtoS(M->RGZ_DTMVTO))) 
		If !lNovo .And. RGZ->(Recno()) <> nRegRGZ .Or. lNovo
			lRet:=.F.
			MsgAlert(STR0020)//"Movimenta��o j� informada!"
		EndIf
	EndIf
	RGZ->(dbGoTo(nRegRGZ))
	If lRet
		oDlgAlter:End()
	EndIf		
ElseIf nFolder == 6
	//�����������������������������������������������������Ŀ
	//� Valida item de rescisao - aba 6                     �
	//�������������������������������������������������������	
	nRegRGY:=RGY->(Recno())
	If RGY->(dbSeek(xFilial("RGY",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+M->RGY_CODIGO))
		If !lNovo .AND. RGY->(Recno())<>nRegRGY .Or. lNovo
			lRet:=.F.
			MsgAlert(STR0021)//"Desconto j� informado!"
		EndIf	
	EndIf
	RGY->(dbGoTo(nRegRGY))
	If lRet
		oDlgAlter:End()
	EndIf
EndIf 

Return( lRet )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601FLD � Autor � Wagner Montenegro  � Data � 30/10/2010 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o de Controle dos Folders de Edi��o Homolognet		   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601FLD()                                                ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function GPEM601FLD(nFldDes, nFldAtu, nReg, nOpcX, oDlg, oFolder)
Local lRet		:= .T.
Local nAlias	:= 0
Local nX		:= 0

//�����������������������������������������������������Ŀ
//� Se for visualizacao oculta os botoes                �
//�������������������������������������������������������	
If nOpcx == 2
	oSButInc2:Hide()
	oSButInc3:Hide()
	oSButInc4:Hide()
	oSButInc5:Hide()
	oSButInc6:Hide()

	oSButAlt2:Hide()
	oSButAlt3:Hide()
	oSButAlt4:Hide()
	oSButAlt5:Hide()
	oSButAlt6:Hide()

	oSButDel2:Hide()
	oSButDel3:Hide()
	oSButDel4:Hide()
	oSButDel5:Hide()
	oSButDel6:Hide()
Endif

//�����������������������������������������������������Ŀ
//� Filtra tabelas                                      �
//�������������������������������������������������������	
RGX->(Eval( bFiltraRGX ))
RGZ->(Eval( bFiltraRGZ ))
RGY->(Eval( bFiltraRGY ))

//�����������������������������������������������������Ŀ
//� Oculta painel de acordo com o clique na aba         �
//�������������������������������������������������������	
If nFldAtu == 1
	oPanel1:Hide()
Elseif nFldAtu == 2
	oPanel2:Hide()
Elseif nFldAtu == 3
	oPanel3:Hide()   
Elseif nFldAtu == 4
	oPanel4:Hide()                
Elseif nFldAtu == 5
	oPanel5:Hide()                
Elseif nFldAtu == 6
	oPanel6:Hide()                
Endif
oFolder:Refresh()

If nFldDes == 1
	//�����������������������������������������������������Ŀ
	//� Exibe o painel 1: Dados Iniciais                    �
	//�������������������������������������������������������	
	For nX := 1 to Len(aPadraoRGW)
	    aPadraoRGW[nX,2] := RGW->&(aPadraoRGW[nX,1]) 
	Next
  	oPanel1:Show()	
Elseif nFldDes == 2
	//�����������������������������������������������������Ŀ
	//� Exibe o painel 2: Dados de ferias                   �
	//�������������������������������������������������������	
	cCondRGW := "RGW_FILIAL=='"+xFilial('RGW',TRB->RA_FILIAL)+"' .AND. RGW_MAT==TRB->RA_MAT .AND. RGW_TPRESC=='1' .AND. RGW_HOMOL==TRB->RG_DATAHOM .AND. RGW_TPREG=='1'" 
	RGW->(Eval( bFiltraRGW))
	oBrowRGW2:GoTop()
  	oPanel2:Show()
Elseif nFldDes == 3
	//�����������������������������������������������������Ŀ
	//� Exibe o painel 3: Dados de 13o                      �
	//�������������������������������������������������������	
	cCondRGW := "RGW_FILIAL=='"+xFilial('RGW',TRB->RA_FILIAL)+"' .AND. RGW_MAT==TRB->RA_MAT .AND. RGW_TPRESC=='1' .AND. RGW_HOMOL==TRB->RG_DATAHOM .AND. RGW_TPREG=='2'" 
	RGW->(Eval( bFiltraRGW))
	oBrowRGW3:GoTop()
  	oPanel3:Show()                
Elseif nFldDes == 4
	//�����������������������������������������������������Ŀ
	//� Exibe o painel 4: Dados financeiro                  �
	//�������������������������������������������������������	
  	oPanel4:Show()   
Elseif nFldDes == 5
	//�����������������������������������������������������Ŀ
	//� Exibe o painel 5: Dados movimentacoes               �
	//�������������������������������������������������������	
  	oPanel5:Show()                
Elseif nFldDes == 6
	//�����������������������������������������������������Ŀ
	//� Exibe o painel 6: Descontos da rescisao             �
	//�������������������������������������������������������	
  	oPanel6:Show()   
Endif
oFolder:nOption

Return( lRet )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601UPD � Autor � Wagner Montenegro  � Data � 30/10/2010 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o de Edi��o e Visualiza��o Homolognet	       		   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601UPD()                                                ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function GPEM601UPD(nFolder, nReg, nOpcX, lNovo, lPdr)
Local aPos			:= {}  	//Enchoice
Local nModelo		:= 3	//Enchoice
Local lF3			:= .F.	//Enchoice
Local lMemoria		:= .T.	//Enchoice
Local lColumn		:= .F.	//Enchoice
Local caTela		:= ""	//Enchoice
Local lNoFolder		:= .F.	//Enchoice
Local lProperty		:= .T.	//Enchoice
Local oGroup		:= Nil	//Enchoice
Local aButtons		:= {}	//Enchoice
Local nOpcao		:= 0	//Enchoice
Local nX            := 0
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aInfoAdvSize	:= {}
Local aObj2Coords	:= {}
Local aAdv2Size		:= {}
Local aObj2Size     := {}
Local aInfo2AdvSize := {}

Private lNovo2		:= lNovo
Private oDlgAlter	:= Nil
Private oEnchAlter	:= Nil
Private aAlteracao  := {}

//�����������������������������������������������������Ŀ
//� Carrega em array posicao dos objetos em tela        �
//�������������������������������������������������������	
aAdvSize        := MsAdvSize(,.T.,370)
aInfoAdvSize    := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 020 , .T. , .F.      } )
aAdd( aObjCoords , { 000 , 100 , .T. , .T., .T. } )
aObjSize    := MsObjSize( aInfoAdvSize , aObjCoords ) // Tratamento odlg

//�����������������������������������������������������Ŀ
//� Carrega em array posicao dos objetos em tela        �
//�������������������������������������������������������	
aAdv2Size     := aClone(aObjSize[2])
aInfo2AdvSize := { 0,0 , aAdv2Size[4] , aAdv2Size[3] , 3 , 5 }
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords)

//�������������������������������������������������Ŀ
//� Seta janela de manutencao                       �
//���������������������������������������������������
oDlgAlter := tDialog():New(aAdvSize[7], 0, aAdvSize[6], aAdvSize[5], STR0004+" - "+If(lNovo,STR0010,STR0011),,,,,,,,, .T.) //"Dados de F�rias" //"Inclus�o","Altera��o"

//�������������������������������������������������Ŀ
//� Seta objeto de abas abaixo do cabecalho         �
//���������������������������������������������������	
TelaCabec(aObjSize, @oDlgAlter)

//�������������������������������������������������������������������������������������������Ŀ
//� Carrega alias, memoria e array de campos que podem ser alterados conforme aba posicionada � 
//���������������������������������������������������������������������������������������������
If nFolder == 2   
	cAliasAlter := 'RGW' 
	RegToMemory('RGW', lNovo, lPdr)
	aAlteracao := aClone(aAltRGW2)
ElseIf nFolder == 3
	cAliasAlter := 'RGW'
	RegToMemory('RGW', lNovo, lPdr)
	aAlteracao := aClone(aAltRGW3)
ElseIf nFolder == 4
	cAliasAlter := 'RGX'
	RegToMemory('RGX', lNovo, lPdr)
	For nX := 1 to Len(aPadraoRGX)
		M->&(aPadraoRGX[nX,1]):= aPadraoRGX[Ascan(aPadraoRGX,{|x|x[1]==aPadraoRGX[nX,1]}),2]
	Next nX 
	aAlteracao := aClone(aAltRGX)
ElseIf nFolder == 5
	cAliasAlter := 'RGZ'
	RegToMemory('RGZ', lNovo, lPdr)
	For nX := 1 to Len(aPadraoRGZ)
		M->&(aPadraoRGZ[nX,1]):= aPadraoRGZ[Ascan(aPadraoRGZ,{|x|x[1]==aPadraoRGZ[nX,1]}),2]
	Next nX 
	aAlteracao := aClone(aAltRGZ)
ElseIf nFolder == 6
	cAliasAlter := 'RGY'
	RegToMemory('RGY', lNovo, lPdr) 
	For nX := 1 to Len(aPadraoRGY)
		M->&(aPadraoRGY[nX,1]):= aPadraoRGY[Ascan(aPadraoRGY,{|x|x[1]==aPadraoRGY[nX,1]}),2]
	Next nX 
	aAlteracao := aClone(aAltRGY)
EndIf 

//������������������������������������Ŀ
//� Posicao dos MsMGet's               �
//��������������������������������������
aPos := {aObj2Size[1,1]+22, aObj2Size[1,2]+2.5, aObj2Size[1,4]+31, aObj2Size[1,3]+10}

//������������������������������������Ŀ
//� Seta MsMGet                        �
//��������������������������������������
oEnchAlter := MsMGet():New(cAliasAlter, nReg, nOpcX,,,, aAlteracao, aPos, aAlteracao, nModelo, ,, , oDlgAlter, lF3, lMemoria, lColumn, caTela, lNoFolder, lProperty)

//������������������������������������Ŀ
//� Abre janela de alteracao           �
//��������������������������������������
oDlgAlter:Activate(,,, .T.,,, ;
					EnchoiceBar(oDlgAlter, {|| IIF(GPEM601TOk(nFolder, lNovo), ;
					IIF(GPEM601GRV(aAlteracao, nOpcX, nFolder, lNovo), nOpcao := 1, ;
					{||nOpcao:=0, oDlgAlter:End()}),nOpcao:=0)},	{||oDlgAlter:End()},,aButtons) ;
				   )

//�������������������������������������������������Ŀ
//� Destrava a tabela confirma a alteracao          �
//���������������������������������������������������	
If nOpcao == 0
	&(cAliasAlter)->(MsUnLock())
EndIf

Return(Nil)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601GRV � Autor � Wagner Montenegro  � Data � 30/10/2010 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o de Grava��o Altera��o/Inclus�o Homolognet	           ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601GRV()                                                ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function GPEM601GRV(aCpos, nOpcX, nFolder, lNovo)
Local aArea 	:= GetArea()
Local nX		:= 0
Local aAlterTab	:= {}

//������������������������������������Ŀ
//� Carrega array com campos alterado  �
//��������������������������������������
If nFolder     == 2
	aAlterTab := aClone( aAltRGW2 )
Elseif nFolder == 3
	aAlterTab := aClone( aAltRGW3 )
Elseif nFolder == 4
	aAlterTab := aClone( aAltRGX )
Elseif nFolder == 5 
	aAlterTab := aClone( aAltRGZ )
Elseif nFolder == 6
	aAlterTab := aClone( aAltRGY )
Endif

//������������������������������������Ŀ
//� Inicia a gravacao                  �
//��������������������������������������
BEGIN TRANSACTION
	RecLock( aHom[nFolder], lNovo )

	If lNovo
		//������������������������������������Ŀ
		//� Inclusao                           �
		//��������������������������������������
		If nFolder <= 3
			For nX := 1 to Len(aPadraoRGW)
				RGW->&(aPadraoRGW[nX,1]) := aPadraoRGW[nX,2]
			Next nX 
			RGW->RGW_ALT	:=	"2"
			RGW->RGW_TPREG	:=	If(nFolder==2,"1","2")	
		Elseif nFolder == 4
			For nX := 1 to Len(aPadraoRGX)
				RGX->&(aPadraoRGX[nX,1]) := aPadraoRGX[nX,2]
			Next nX 	
			RGX->RGX_ALT	:=	"2"
		Elseif nFolder == 5
			For nX := 1 to Len(aPadraoRGZ)
				RGZ->&(aPadraoRGZ[nX,1]) := aPadraoRGZ[nX,2]
			Next nX 	
			RGZ->RGZ_ALT	:=	"2"
		Elseif nFolder == 6
			For nX := 1 to Len(aPadraoRGY)
				RGY->&(aPadraoRGY[nX,1]) := aPadraoRGY[nX,2]
			Next nX 	
			RGY->RGY_ALT	:=	"2"
		Endif
	EndIf	
	//������������������������������������Ŀ
	//� Alteracao                          �
	//��������������������������������������
	For nX := 1 to Len( aAlterTab )
	   If nFolder <= 3
			RGW->&(aAlterTab[nX]) := M->&(aAlterTab[nX])
			If !lNovo
				RGW->RGW_ALT :=	"3"
			EndIf
		Elseif nFolder == 4
			RGX->&(aAlterTab[nX]) := M->&(aAlterTab[nX])
			If !lNovo
				RGX->RGX_ALT :=	"3"
			EndIf
		Elseif nFolder == 5
			RGZ->&(aAlterTab[nX]) := M->&(aAlterTab[nX])
			If !lNovo
				RGZ->RGZ_ALT :=	"3"
			EndIf
		Elseif nFolder == 6
			RGY->&(aAlterTab[nX]) := M->&(aAlterTab[nX])
			If !lNovo
				RGY->RGY_ALT :=	"3"
			EndIf
		Endif
	Next nX
	&(aHom[nFolder])->(MsUnLock())
END TRANSACTION

Return(.T.)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601DEL � Autor � Wagner Montenegro  � Data � 30/10/2010 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o de Exclus�o dos dados de Tabelas Homolognet	       ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601DEL()                                                ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL 											           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function GPEM601DEL(nFolder, nReg, nOpcX, lNovo, lPdr)
Local lRet		:= .F.
Local aExcMAT	:= { "", "", "RGW_MAT"   , "RGX_MAT"   , "RGZ_MAT"   , "RGY_MAT"	}
Local aExcHOM	:= { "", "", "RGW_HOMOL" , "RGX_HOMOL" , "RGZ_HOMOL" , "RGY_HOMOL"	}
Local aExcTPR	:= { "", "", "RGW_TPRESC", "RGX_TPRESC", "RGZ_TPRESC", "RGY_TPRESC" }
Local nX		:= 0
Local cFilCpo	:= ''
Local cMat		:= ''
Local dHom		:= CtoD('//')
Local cTPR		:= ''
Local cFilAlias := ''
Local aAreaTRB	:= TRB->(GetArea())
Local cAliasDel := ''
Default nFolder	:= 0
Default lNovo	:= .F.

If nFolder == 0
	If apMsgNoYes(STR0022+TRB->RA_MAT+STR0023) //"Confirma a exclus�o dos registros do Homolognet para a Matricula[" //"]?"
		For nX := 3 to 6
			cAliasDel := aHom[nX] 
			If &(cAliasDel)->(dbSeek(xFilial(cAliasDel, TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)))
				cFilCpo		:= cAliasDel+"->"+PrefixoCpo(aHom[nX])+"_FILIAL" 
				cMat		:= cAliasDel+"->"+aExcMAT[nX]
				dHom		:= cAliasDel+"->"+aExcHOM[nX]
				cTPR		:= cAliasDel+"->"+aExcTPR[nX]
				cFilAlias	:= &cFilCpo	
				While !&(cAliasDel)->(Eof()) .And. ;
						(cAliasDel)->(&cFilCpo	) == cFilAlias 			.AND. ;
						(cAliasDel)->(&cMat		) == TRB->RA_MAT 		.AND. ;
						(cAliasDel)->(&dHom		) == TRB->RG_DATAHOM 	.AND. ;
						(cAliasDel)->(&cTPR		) == '1'
					RecLock(cAliasDel, lNovo)
					&(cAliasDel)->(dbDelete())
					&(cAliasDel)->(MsUnLock())
					&(cAliasDel)->(dbSkip())
				EndDo
			Endif
		Next
		RecLock("TRB",lNovo)
		TRB->(dbDelete())
		TRB->(MsUnLock())
		RestArea(aAreaTRB)
		TRB->(dbGoTop())
	Endif
Else
	If apMsgNoYes(STR0024)//"Confirma a exclus�o?"
		cAliasDel := aHom[nFolder] 
		RecLock(cAliasDel, lNovo)
		&(cAliasDel)->(dbDelete())
		&(cAliasDel)->(MsUnLock())
		If(nFolder <= 3, Eval( bFiltraRGW ),If(nFolder==4,Eval( bFiltraRGX ),If(nFolder==5,Eval( bFiltraRGZ ),Eval( bFiltraRGY ))))
		lRet := .T.
	Endif
Endif	

Return(lRet)
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MenuDef  � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados		  ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MenuDef() 
Local aRotina := {	{ STR0026, "GPEM601MAN('TRB',TRB->(Recno()),4)"	,0,4,,.F.},;	// "Manuten��o"
					{ STR0027, "GPEM601MAN('TRB',TRB->(Recno()),2)"	,0,2,,.F.},;	// "Visualiza��o"
					{ STR0028, "GPEM601Del()"						,0,4,,.F.},;	// "Exclus�o"
					{ STR0029, "GPEM601LGD('TRB',TRB->(Recno()))"  	,0,3,,.F.}	}	// "Legenda"
Return(aRotina)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ�
���Fun��o	 � GPEM601LGD � Autor � Wagner Montenegro	� Data � 30.10.2010	��
���������������������������������������������������������������������������Ĵ�     
���Descri��o � Exibe a legenda Homolognet                   			    ��
���������������������������������������������������������������������������Ĵ�
���Retorno	 � Nenhum       											   	��
���������������������������������������������������������������������������Ĵ�
���Sintaxe	 � GPEM601LGD()												  	��
���������������������������������������������������������������������������Ĵ�
���Uso		 � Brasil                   					   				��
����������������������������������������������������������������������������ٱ
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function GPEM601LGD(cAlias, nReg)
Local aLegenda	:= {	{"BR_VERDE"		, STR0030	},;		// 01 - "XML n�o gerado"
						{"BR_VERMELHO"	, STR0031	} }		// 02 - "XML Gerado"

Local uRetorno	:= .T.

//��������������������������������������������������������������������Ŀ
//� Chamada direta da funcao onde nao passa, via menu Recno eh passado �
//����������������������������������������������������������������������
If nReg == Nil	
	uRetorno := {}
	Aadd(uRetorno, { 'EMPTY(RGW_NUMID)' , aLegenda[1][1] } )
	Aadd(uRetorno, { '!EMPTY(RGW_NUMID)', aLegenda[2][1] } )
Else
	BrwLegenda(STR0001, STR0029, aLegenda) //"Homolognet", "Legenda"
Endif  

Return(uRetorno)
					
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601RGY � Autor � Wagner Montenegro  � Data � 30/10/2010 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o usada tambem na clausula VALID no SX3             ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601RGY()                                                ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function GPEM601RGY(cFilRGY, cMat, cTpResc, dHomol, cCodDescto, cTpReg)
Local aAreaAtu	:= GetArea()
Local aAreaSRV	:= SRV->(GetArea())
Local aAreaRGY	:= RGY->(GetArea())
Local lRet		:= .T.
Local nRegRGY   := 0

Default cCodDescto := ""

If cTpReg == "2"
	nRegRGY := RGY->(Recno())  
	GPEM601V04(M->RGY_TPREG,4,M->RGY_CODIGO)
	RGY->(dbSetOrder(1))
	SRV->(dbSetOrder(1))
	If RGY->( dbSeek( xFilial("RGY", TRB->RA_FILIAL)+cMat+cTpResc+DTOS(dHomol)+cCodDescto ) )
		If !lNovo2 .AND. RGY->(Recno()) <> nRegRGY .or. lNovo2
			lRet := .F.
			MsgAlert(STR0032)//"Registro de Desconto j� informado!"
		Endif
	Else
		If SRV->( dbSeek( xFilial("SRV", TRB->RA_FILIAL)+cCodDescto))
	      If SRV->RV_TIPOCOD <> '2'
	         lRet:=.F.
	         MsgAlert(STR0033)//"Este c�digo n�o corresponde a Desconto!"
	      Endif
	   Endif   
	Endif
Else
	
	//���������������������������������������������������������������������������������������������������������������Ŀ
	//� Inclusao de novos descontos - SEMPRE Verificar as funcoes GPEM601RGY; GPEM601V04 e Registro8 do fonte GPEM602 �
	//�����������������������������������������������������������������������������������������������������������������
	If !(cCodDescto $ "A01/A02/A03/A04/A05/A06/A07/A08/A09/A10/A11/A12/A13/A14/A15")
		lRet	:=	.F.
		MsgAlert(STR0034)//"Registro n�o encontrado!"
	Else
		nRegRGY := RGY->(Recno()) 
		RGY->(dbSetOrder(1))
		If RGY->( dbSeek( xFilial("RGY",TRB->RA_FILIAL)+cMat+cTpResc+DTOS(dHomol)+cCodDescto ) )
			If !lNovo2 .And. RGY->(Recno()) <> nRegRGY .Or. lNovo2
				lRet := .F.
				MsgAlert(STR0032)//"Registro de Desconto j� informado!"
			Endif
		Endif
	Endif
Endif

RestArea(aAreaSRV)		
RestArea(aAreaRGY)
RestArea(aAreaAtu)

Return( lRet )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601RGZ � Autor � Wagner Montenegro  � Data � 30/10/2010 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao usada tambem na clausula VALID no SX3             ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601RGZ()                                                ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function GPEM601RGZ(cFilRGZ, cMat, cTpResc, dHomol, cMotivo, dMvto)
Local aAreaAtu	:= GetArea()
Local aAreaRGZ	:= RGZ->(GetArea())
Local lRet		:= .T.
 
//�������������������������������������������Ŀ
//� Inclusao de novos afastamentos - Q7 e Z20 �
//���������������������������������������������
If AllTrim(cMotivo) $ "M/N1/N2/O1/O2/O3/P1/P2/P3/Q1/Q2/Q3/Q4/Q5/Q6/Q7/R/S2/S3/U1/U3/W/X1/X2/X3/Y/Z1/Z2/Z3/Z4/Z6/Z7/Z8/Z9/Z10/Z11/Z12/Z13/Z14/Z15/Z16/Z17/Z18/Z19/Z20"
	If RGZ->(dbSeek(  xFilial("RGX",TRB->RA_FILIAL)+cMat+cTpResc+Dtos(dHomol)+cMotivo+Dtos(dMvto) ))
   		lRet := .F.
		MsgAlert( STR0035 )		// "O C�digo de Movimenta��o informado j� existe para esta data!"
	Endif   
Else
	lRet := .F.
	MsgAlert( STR0036 )			// "C�digo de Movimenta��o n�o encontrado!"
Endif

RestArea(aAreaRGZ)
RestArea(aAreaAtu)

/*
�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
�M   - Mudan�a de regime estatut�rio                                                                                                                                                  �
�N1  - Transf. empregado p/ outro estabelecimento da mesma empresa                                                                                                                    �
�N2  - Transf. empregado p/ outra empresa que tenha assumido os encargos trab., sem que tenha havido rescis�o de contrato de trabalho                                                 �
�O1  - Afastamento tempor�rio por motivo de acidente do trabalho, por per�odo superior a 15 dias                                                                                      �
�O2  - Novo afastamento tempor�rio em decorr�ncia do mesmo acidente do trabalho                                                                                                       �
�O3  - Afastamento tempor�rio por motivo de acidente do trabalho, por per�odo igual ou inferior a 15 dias                                                                             �
�P1  - Afastamento tempor�rio por motivo de doen�a, por per�odo superior a 15 dias"                                                                                                   �
�P2  - Novo afastamento tempor�rio em decorr�ncia da mesma doen�a, dentro de 60 dias contados da cessa��o do afastamento anterior"                                                    �
�P3  - Afastamento tempor�rio por motivo de doen�a, por per�odo igual ou inferior a 15 dias                                                                                           �
�Q1  - Afastamento tempor�rio por motivo de licen�a-maternidade (120 dias)                                                                                                            �
�Q2  - Prorroga��o do afastamento tempor�rio por motivo de licen�a-maternidade                                                                                                        �
�Q3  - Afastamento tempor�rio por motivo de aborto n�o criminoso                                                                                                                      �
�Q4  - Afastamento tempor�rio por motivo de licen�a-maternidade decorrente de ado��o ou guarda judicial de crian�a at� 1 (um) ano de idade (120 dias)                                 �
�Q5  - Afastamento tempor�rio por motivo de licen�a-maternidade decorrente de ado��o ou guarda judicial de crian�a a partir de 1 (um) ano at� 4 (quatro) anos de idade (60 dias)      �
�Q6  - Afastamento tempor�rio por motivo de licen�a-maternidade decorrente de ado��o ou guarda judicial de crian�a a partir de 4 (quatro) anos at� 8 (oito) anos de idade (30 dias)   �
�Q7  - Prorroga��o da dura��o da licen�a-maternidade - Programa Empresa Cidad� - Lei no. 11.770/2008                                                                                  �
�R   - Afastamento tempor�rio para prestar servi�o militar                                                                                                                            �
�S2  - Falecimento                                                                                                                                                                    � 
�S3  - Falecimento motivado por acidente de trabalho                                                                                                                                  �
�U1  - Aposentadoria por tempo de contribui��o ou idade sem continuidade de v�nculo empregat�cio                                                                                      �
�U3  - Aposentadoria por invalidez                                                                                                                                                    �
�W   - Afastamento tempor�rio para exerc�cio de mandato sindical                                                                                                                      �
�X1  - Licen�a com percep��o de sal�rio                                                                                                                                               �
�X2  - Licen�a sem percep��o de sal�rio                                                                                                                                               �
�X3  - Afastamento por suspens�o do contrato de trabalho prevista no art. 476-A da CLT                                                                                                �
�Y   - Outros motivos de afastamento tempor�rio                                                                                                                                       �
�Z1  - Retorno de afastamento tempor�rio por motivo de licen�a-maternidade, informado pela movimenta��o Q1                                                                            �
�Z2  - Retorno de afastamento tempor�rio por motivo de acidente do trabalho, por per�odo superior a 15 dias, informado pela movimenta��o O1                                           �
�Z3  - Retorno de novo afastamento tempor�rio em decorr�ncia do mesmo acidente do trabalho, informado pela movimenta��o O2                                                            �
�Z4  - Retorno do afastamento tempor�rio para prestar servi�o militar obrigat�rio, informado pela movimenta��o R                                                                      �
�Z6  - Retorno de afastamento tempor�rio por motivo de acidente do trabalho, por per�odo igual ou inferior a 15 dias, informado pela movimenta��o O3                                  �
�Z7  - Retorno de afastamento tempor�rio por motivo de doen�a, por per�odo superior a 15 dias, informado pela movimenta��o P1                                                         �
�Z8  - Retorno de novo afastamento tempor�rio em decorr�ncia da mesma doen�a, dentro de 60 dias contados da cessa��o do afastamento anterior, informado pela movimenta��o P2          �
�Z9  - Retorno de licen�a com percep��o de sal�rio, informado pela movimenta��o X1                                                                                                    �
�Z10 - Retorno de licen�a sem percep��o de sal�rio, informado pela movimenta��o X2                                                                                                    �
�Z11 - Retorno da aposentadoria por invalidez, informado pela movimenta��o U3                                                                                                         �
�Z12 - Retorno do afastamento tempor�rio para exerc�cio de mandato sindical, informado pela movimenta��o W                                                                            �
�Z13 - Retorno do afastamento tempor�rio por motivo de aborto n�o criminoso, informado pela movimenta��o Q3                                                                           �
�Z14 - Retorno da prorroga��o do afastamento tempor�rio por motivo de licen�amaternidade, informado pela movimenta��o Q2                                                              �
�Z15 - Retorno de afastamento tempor�rio por motivo de licen�a-maternidade, informado pela movimenta��o Q4                                                                            �
�Z16 - Retorno de afastamento tempor�rio por motivo de licen�a-maternidade, informado pela movimenta��o Q5                                                                            �
�Z17 - Retorno de afastamento tempor�rio por motivo de licen�a-maternidade, informado pela movimenta��o Q6                                                                            �
�Z18 - Retorno de afastamento tempor�rio por motivo de doen�a, por per�odo igual ou inferior a 15 dias, informado pela movimenta��o P3                                                �
�Z19 - Retorno do afastamento por suspens�o do contrato de trabalho prevista no art. 476-A da CLT, informado pela movimenta��o X3                                                     �
�Z20 - Retorno de afastamento tempor�rio por motivo de licen�a-maternidade (Programa Empresa Cidad�) - Q7                                                                             �
���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������*/
Return( lRet )

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601V01 � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
������������������������������������������ ��������������������������������Ĵ��
���Descri��o � Validacao usada tambem na clausula VALID no SX3              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601V01()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function GPEM601V01()
Local lRet := .F.

If M->RGX_TPREG == "1" .And. !(M->RGX_CODRUB $ "003/004/012/013/014/015/016/018/019/035") .Or. M->RGX_TPREG == "2"
	lRet := .T.
Endif

Return( lRet )
	
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601V02 � Autor � Wagner Montenegro  � Data � 30/10/2010 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao usada tambem na clausula VALID no SX3             ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601V02(                                                 ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  												       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function GPEM601V02()
Local lRet := .F.

IF M->RGX_TPREG == '1' .And. M->RGX_CODRUB $ '004/012/013/014/015/016/018/019'
	lRet := .T.
Endif

Return( lRet )

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601V03 � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao usada tambem na clausula VALID no SX3              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601V03()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  												        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function GPEM601V03()
Local lRet := .F.

IF M->RGX_TPREG == '1' .And. M->RGX_CODRUB $ '004/012/015/016/035' .Or. M->RGX_TPREG == '1' .And. M->RGX_CODRUB == '005' .And. M->RGX_TPSAL == '1'
	lRet := .T.
ENDIF

Return( lRet )

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601V04 � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao usada tambem na clausula VALID no SX3              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601V04()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function GPEM601V04(cOpc, nModo, cBusca, nFolder)
Local aArea	:= GetArea()
Local aStru	:= {}
Local cArqb := ''
Local cIndb := ''
Local aSit  := {}
Local nX    := 0
Local lRet	:= .T.

Default nModo	:= 0
Default cOpc	:= ""
Default cBusca	:= ""   
Default nFolder	:= 0

If FUNNAME() == "GPEA040" .Or. FUNNAME()=="GPEA120"
	If Select("RCC")>0
		RCC->(DbCloseArea())
	Endif
Endif

If cOpc == "2" .And. nModo == 0 .Or. cOpc == "1" .And. nModo == 5

	If nFolder == 4
		oEnchAlter:oBox:Cargo[5]:cF3 := 'S20'
	Elseif nFolder == 6
		oEnchAlter:oBox:Cargo[2]:cF3 := 'S20'
	Endif
	If Select("RCC")>0
		RCC->(DbCloseArea())
	Endif

	aAdd(aStru, {"RCC_FILIAL", "C", FWGETTAMFILIAL, 00})
	aAdd(aStru, {"RCC_CODIGO", "C", 004           , 00})
	aAdd(aStru, {"RCC_FIL"	 , "C", 002           , 00})
	aAdd(aStru, {"RCC_CHAVE" , "C", 006           , 00})
	aAdd(aStru, {"RCC_SEQUEN", "C", 003           , 00})
	aAdd(aStru, {"RCC_CONTEU", "C", 250           , 00})

	oTmpRCC := FWTemporaryTable():New("RCC")
	oTmpRCC:SetFields( aStru )
	aOrdem	:=	{"RCC_FILIAL", "RCC_CODIGO", "RCC_FIL", "RCC_CHAVE", "RCC_SEQUEN"}
	oTmpRCC:AddIndex("IN1", aOrdem)
	oTmpRCC:Create()

	//�����������������������������������������������������������������������������������������������������������������������������Ŀ
	//� Inclusao de novos descontos - A14 e A15 - SEMPRE Verificar as funcoes GPEM601RGY; GPEM601V04 e a Registro8 do fonte GPEM602 �
	//�������������������������������������������������������������������������������������������������������������������������������
	aSit :={	;
				{"xFilial('RCC')", "S020", "", "", "001", "A01Adiantamento Salarial                                 "},;
				{"xFilial('RCC')", "S020", "", "", "002", "A02Adiantamento 13� Sal�rio                              "},;
				{"xFilial('RCC')", "S020", "", "", "003", "A03Faltas injust. no m�s/rescis�o acresc. do DSR corresp."},;  
				{"xFilial('RCC')", "S020", "", "", "004", "A04Valor total Gasto com Vale Transporte                 "},;
				{"xFilial('RCC')", "S020", "", "", "005", "A05Desconto Vale Alimenta��o                             "},;
				{"xFilial('RCC')", "S020", "", "", "006", "A06Reembolso de Vale Transporte                          "},;
				{"xFilial('RCC')", "S020", "", "", "007", "A07Reembolso de Vale Alimenta��o                         "},;
				{"xFilial('RCC')", "S020", "", "", "008", "A08Saldo devedor de empr�stimo consignado                "},;
				{"xFilial('RCC')", "S020", "", "", "009", "A09Indeniza��o Art 480 CLT                               "},;  
				{"xFilial('RCC')", "S020", "", "", "010", "A10Contribui��es para previd�ncia privada                "},;
				{"xFilial('RCC')", "S020", "", "", "011", "A11Contribui��es para FAPI                               "},;
				{"xFilial('RCC')", "S020", "", "", "012", "A12Outras dedu��es para base de c�lculo IRRF             "},;
				{"xFilial('RCC')", "S020", "", "", "013", "A13Contribui��o sindical laboral Art 580 CLT             "},;
				{"xFilial('RCC')", "S020", "", "", "014", "A14Compensa��o Dias Sal�rio F�rias M�s Afastamento	    "},;
				{"xFilial('RCC')", "S020", "", "", "015", "A15Complementa��o IRRF Rendimento M�s Quita��o		    "};
		   }

	For nX := 1 to Len(aSit)
		Reclock("RCC",.T.)
		RCC->RCC_FILIAL := xFilial('RCC')
		RCC->RCC_CODIGO := aSit[nx,2]
		RCC->RCC_FIL    := aSit[nx,3]
		RCC->RCC_CHAVE  := aSit[nx,4]
		RCC->RCC_SEQUEN := aSit[nx,5]
		RCC->RCC_CONTEU := aSit[nx,6]
		RCC->(MsUnlock())
	Next	
	RCC->(dbGoTop())
	
Elseif cOpc=="2" .and. nModo==1 .or. cOpc=="1" .and. nModo==6
	If nFolder==4
		oEnchAlter:OBOX:CARGO[5]:CF3:='S20'
	Elseif nFolder==6
		oEnchAlter:OBOX:CARGO[2]:CF3:='S20'	
	Endif
	If !(cBusca $ "A01/A02/A03/A04/A05/A06/A07/A08/A09/A10/A11/A12/A13/A14/A15")
		lRet	:=	.F.
		MsgAlert(STR0034)//"Registro n�o encontrado!"
	Endif
	If Select("RCC") > 0
		RCC->(dbCloseArea())
	Endif
Elseif cOpc=="2" .and. nModo==3
	If nFolder==4
		oEnchAlter:OBOX:CARGO[5]:CF3:='SRV'
	Elseif nFolder==6
		oEnchAlter:OBOX:CARGO[2]:CF3:='SRV'		
	Endif
Elseif cOpc=="2" .and. nModo==4  .or. cOpc=="2" .and. nModo==5
	If nFolder==4
		oEnchAlter:OBOX:CARGO[5]:CF3:='SRV'
	Elseif nFolder==6
		oEnchAlter:OBOX:CARGO[2]:CF3:='SRV'		
	Endif
	If !SRV->(dbSeek(xFilial("SRV")+cBusca))
	   lRet:=.F.
	   MsgAlert(STR0037) //"C�digo de Rubrica n�o localizado no Cadastro de Verbas!"
	Endif
Elseif cOpc=="1" .And. nModo <> 0 .And. nModo <> 5
	If nFolder == 4
		oEnchAlter:OBOX:CARGO[5]:CF3:='S20'
	Elseif nFolder==6
		oEnchAlter:OBOX:CARGO[2]:CF3:='S20'		
	Endif
	If Select("RCC") > 0
		RCC->(dbCloseArea())
	Endif
	dbSelectArea("RCC")
Endif

RestArea( aArea )
Return( lRet )

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM601PSQ � Autor � Wagner Montenegro   � Data � 30/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para pesquisa no TRB						            ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM601PSQ()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � BRASIL  													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function GPEM601PSQ()
Local cFilMat		:= Space(Len(TRB->RA_FILIAL))
Local cMat			:= Space(Len(TRB->RA_MAT))
Local nRecOld		:= TRB->(Recno())
Local cBOk			:= 0
Local oDlgPsq		:= Nil
Local oGrpPsq		:= Nil
Local aAdvSize		:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aInfoAdvSize	:= {}
Local bSet15        := {}
Local bSet24		:= {}
Local oGroupFil		:= Nil
Local oGroupMat		:= Nil
Local oGetFil		:= Nil
Local oGetMat		:= Nil

//�������������������������������������������������Ŀ
//� Pega posicao dos objetos em tela                �
//���������������������������������������������������
aAdvSize        := MsAdvSize(,.T.,370)
aInfoAdvSize    := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )
aObjSize        := MsObjSize( aInfoAdvSize , aObjCoords )

//�������������������������������������������������Ŀ
//� Seta janela de Pesquisa                         �
//���������������������������������������������������
oDlgPsq := tDialog():New(aAdvSize[7], 0, aAdvSize[6]*0.40, aAdvSize[5], STR0025,,,,,,,,, .T.) //"Pesquisa"

//�������������������������������������������������Ŀ
//� Seta grupo da janela de pesquisa                �
//���������������������������������������������������
oGroupFil  := TGroup():Create( oDlgPsq, aObjSize[1][1], aObjSize[1][4] * 0.185  , aObjSize[1][3], aObjSize[1][4] * 0.18, TitSX3("RA_FILIAL")[1]   ,,, .T.) // "Filial:"
oGroupMat  := TGroup():Create( oDlgPsq, aObjSize[1][1], aObjSize[1][2]	        , aObjSize[1][3], aObjSize[1][4]       , TitSX3("RA_MAT")[1]      ,,, .T.) // "Matricula:" 
oGroupFil:oFont := oFont
oGroupMat:oFont := oFont 

//�������������������������������������������������Ŀ
//� Seta get da janela de pesquisa                  �
//���������������������������������������������������
oGetFil:Create( oDlgPsq, {|| TamSx3("RA_FILIAL")[1]}, aObjSize[1,1] + 10, aObjSize[1,2] * 2.5, 030, 010,,,,, oFont,,, .T.)
oGetMat:Create( oDlgPsq, {|| TamSx3("RA_MAT")[1]}   , aObjSize[1,1] + 10, aObjSize[1,2] * 0,2, 060, 010,,,,, oFont,,, .T.)

//�������������������������������������������������Ŀ
//� Seta bloco de validacao da pesquisa             �
//���������������������������������������������������
bSet15 := {|| If(!Empty(cFilMat) .and. !Empty(cMat),If(TRB->(dbSeek(cFilMat+cMat)),oDlgPsq:End(),MsgAlert(STR0034)),MsgAlert(STR0038))}
bSet24 := {|| TRB->(dbGoTo(nRecOld)),oDlgPsq:End()}

//�������������������������������������������������Ŀ
//� Abre janela                                     �
//���������������������������������������������������
oDlgPsq:Activate(,,, .T.,,, EnchoiceBar(oDlgPsq, bSet15, bSet24) )

Return(.T.)