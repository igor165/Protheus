#Include "RwMake.ch"
#Include "Protheus.CH"   
#Include "HeaderGD.CH"
#Include "GPEM601.CH"

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEM601  ³ Autor  ³ WAGNER MONTENEGRO                 ³ Data ³ 30/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao das Tabelas de Dados do Homolognet                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Requisito         ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Bruno Nunes ³29/01/14³ 001975_01         ³ Unificacao da Homolognet da versao 11.80 ³±±
±±³            ³        ³                   ³ com a fase 4                             ³±±
±±³Gustavo M.  ³24/05/16³ TVDLPV         	³ Correcao na pesquisa.					   ³±±
±±³Cícero Alves³28/04/17³ DRHPAG-242        ³ Usar FWTemporaryTable para a criação  de ³±±
±±³			   ³	    ³          			³ tabelas temporárias					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega tabela temporia como tela inicial        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CarTelaIni(@aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama tabela temporaria em mBrowse               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
If TRB->(EOF()) .and. TRB->(BOF())		
	Help(" ",1,"RECNO")
Else	
	mBrowse( 6, 1, 22, 75, "TRB", aCampos,,,,, GPEM601LGD("TRB"))
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fecha tabela temporaria                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601MAN ³ Autor ³ Wagner Montenegro  ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função de Manutenção Homolognet		  					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601MAN()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 							"Dados Iniciais", "Dados de Férias", "Dados de 13º", "Dados Financeiros", "Movimentações", "Descontos da Rescisão" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aFolder     := { STR0003, STR0004, STR0005, STR0006, STR0007, STR0008 }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Condicao do filtro                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCondRGW	:= "RGW_FILIAL=='"	+xFilial('RGW',TRB->RA_FILIAL)+"' .AND. RGW_MAT==TRB->RA_MAT" 
Private cCondRGX  	:= "RGX_FILIAL=='"	+xFilial('RGX',TRB->RA_FILIAL)+"' .AND. RGX_MAT==TRB->RA_MAT .AND. RGX_TPRESC=='1' .AND. RGX_HOMOL==TRB->RG_DATAHOM" 
Private cCondRGY  	:= "RGY_FILIAL=='"	+xFilial('RGY',TRB->RA_FILIAL)+"' .AND. RGY_MAT==TRB->RA_MAT .AND. RGY_TPRESC=='1' .AND. RGY_HOMOL==TRB->RG_DATAHOM" 
Private cCondRGZ  	:= "RGZ_FILIAL=='"	+xFilial('RGZ',TRB->RA_FILIAL)+"' .AND. RGZ_MAT==TRB->RA_MAT .AND. RGZ_TPRESC=='1' .AND. RGZ_HOMOL==TRB->RG_DATAHOM" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Leitura da chave nas tabelas                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RGW->(dbSeek(xFilial("RGW",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+'1'))
RGX->(dbSeek(xFilial("RGX",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)))
RGZ->(dbSeek(xFilial("RGZ",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)))
RGY->(dbSeek(xFilial("RGY",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa Filtro                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval( bFiltraRGW )
Eval( bFiltraRGX )
Eval( bFiltraRGZ )
Eval( bFiltraRGY )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega tela manutencao                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CarTelaMenu(cAlias, nReg, nOpcX)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa filtros                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RGW",aIndexRGW)
EndFilBrw("RGX",aIndexRGX)
EndFilBrw("RGZ",aIndexRGZ)
EndFilBrw("RGY",aIndexRGY)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CarTelaIni ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CarTelaMenu³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega nos arrays posicoes dos objetos de tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PosObjAba(@aObjSize, @aObj2Size, @aObj3Size, @aObj4Size, @aAdvSize)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta janela de manutencao                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgGeral := tDialog():New(aAdvSize[7], 0, aAdvSize[6], aAdvSize[5], STR0009,,,,,,,,, .T.) // "Manutenção Homolognet"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega campos do cabecalho da tela de manutencao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
TelaCabec(aObjSize, @oDlgGeral)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta objeto de abas abaixo do cabecalho         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
oFolder 	:= TFolder():New(aObjSize[2,1], aObjSize[2,2], aFolder, aFolder, oDlgGeral,,,, .T., ,aObjSize[2,3], aObjSize[2,4] )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega variaveis dos campos                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
RegToMemory('RGW', .F., .T.)
RegToMemory('RGX', .F., .T.)
RegToMemory('RGY', .F., .T.)
RegToMemory('RGZ', .F., .T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega abas da tela de manutencao              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
CarPanel1(aObj2Size, cAlias, nReg, nOpcX)
CarPanel2(aObj3Size, cAlias, nReg, nOpcX)
CarPanel3(aObj3Size, cAlias, nReg, nOpcX)
CarPanel4(aObj3Size, cAlias, nReg, nOpcX)
CarPanel5(aObj3Size, cAlias, nReg, nOpcX)
CarPanel6(aObj3Size, cAlias, nReg, nOpcX)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloco de codigo chamado na troca de aba                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder:bSetOption	:= {|nAtu| GPEM601FLD(nAtu, oFolder:nOption, nReg, nOpcX, oDlgGeral, oFolder)}
bRefresh			:= {|| oDlgGeral:oFolder:Refresh() }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta botao cancelar na janela de dialago                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButCan := SButton():New( aObjSize[3,1]+5, aObjSize[3,4]-25,2, {||oDlgGeral:End(), nOpca:=0}, oDlgGeral, .T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta o dialogo.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgGeral:Activate (,,, .T.)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PosObjAba  ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega informacoes dos objetos em telas           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdvSize        := MsAdvSize()
aInfoAdvSize    := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 3 , 3 }
aAdd( aObjCoords , { 000 , 020 , .T. , .F.     } )
aAdd( aObjCoords , { 000 , 100 , .T. , .T. ,.T.} )
aAdd( aObjCoords , { 000 , 020 , .T. , .F.     } )
aObjSize    := MsObjSize( aInfoAdvSize , aObjCoords ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utilizado na getdados da primeira aba do folder ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdv2Size     := aClone(aObjSize[2])
aInfo2AdvSize := { 0 , 0 , aAdv2Size[4] , aAdv2Size[3] , 2 , 2 }
aAdd( aObj2Coords , { 000 , 100 , .T. , .T. } )
aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utilizado nas listbox das demais abas           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdv3Size     := aClone(aObjSize[2])
aInfo3AdvSize := { 0 , 0 , aAdv3Size[3] , aAdv3Size[4] , 2 , 2 }
aAdd( aObj3Coords , { 000 , 100 , .T. , .T., .T. } )
aAdd( aObj3Coords , { 000 , 040 , .T. , .F.      } )
aObj3Size := MsObjSize( aInfo3AdvSize , aObj3Coords )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utilizado na getdados da primeira aba do folder ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdv4Size     := aClone(aObj2Size[1])
aInfo4AdvSize := { 0 , 0 , aAdv4Size[3] , aAdv4Size[4] , 5 , 5 }
aAdd( aObj4Coords , { 000 , 000 , .T. , .T. } )
aObj4Size := MsObjSize( aInfo4AdvSize , aObj4Coords)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TelaCabec  ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TelaCabec(aObjSize, oDlgPai)
Local oGroupMat  := Nil 
Local oGroupNome := Nil 
Local oGroupAdi  := Nil
Local oSayMat    := Nil
Local oSayNome   := Nil
Local oSayAdi    := Nil
 
oGroupMat  := TGroup():Create( oDlgPai, aObjSize[1][1], aObjSize[1][2]	      , aObjSize[1][3], aObjSize[1][4] * 0.18, TitSX3("RA_MAT")[1]    ,,, .T.) // "Matricula:" 
oGroupNome := TGroup():Create( oDlgPai, aObjSize[1][1], aObjSize[1][4] * 0.185  , aObjSize[1][3], aObjSize[1][4] * 0.87, TitSX3("RA_NOME")[1]   ,,, .T.) // "Nome:"
oGroupAdi  := TGroup():Create( oDlgPai, aObjSize[1][1], aObjSize[1][4] * 0.875  , aObjSize[1][3], aObjSize[1][4]       , TitSX3("RA_ADMISSA")[1],,, .T.) // "Admiss„o:"

oGroupMat:oFont  := oFont 
oGroupNome:oFont := oFont
oGroupAdi:oFont  := oFont

oSayMat   := TSay():Create(oDlgPai , {|| Dtoc(TRB->RA_ADMISSA)}	, aObjSize[1][1] + 10, aObjSize[1][4] * 0.89,, oFont,,,, .T.,,, 050, 010)
oSayNome  := TSay():Create(oDlgPai , {|| TRB->RA_MAT}				, aObjSize[1][1] + 10, aObjSize[1][2] * 2.50,, oFont,,,, .T.,,, 050, 010)
oSayAdi   := TSay():Create(oDlgPai , {|| If(lOfuscaNom,Replicate('*',15),OemToAnsi(TRB->RA_NOME))}	, aObjSize[1][1] + 10, aObjSize[1][4] * 0.20,, oFont,,,, .T.,,, 146, 010)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CarPanel1  ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta painel na aba 1                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel1 := TPanel():New(nTop, nLeft, '', oFolder:aDialogs[1],, .T., .T.,,, nWidth, nHeight,.F.,.F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega para memoria varievais dos campos RGW   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpoRGW1 := {"RGW_FILIAL","RGW_MAT","RGW_HOMOL","RGW_TPRESC","RGW_JTCUMP","RGW_COMPSA","RGW_FM13","RGW_PER13","RGW_QTDE13",;
  			 "RGW_MA13","RGW_FMFER","RGW_PERFER","RGW_QTDFER","RGW_MAFER","RGW_FMAV","RGW_QTDEAV","RGW_MAAV","RGW_DAVISO","RGW_NUMID","RGW_CCUSTO"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta enchoice dentro do painel 1                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  					 
oEnch1	 := MsMGet():New('RGW', nReg, 2, , ,, aCpoRGW1, {nTop, nLeft, nHeight-15, nWidth-3}, aCpoRGW1, nModelo,,,, oPanel1, lF3, lMemoria, lColumn, caTela, lNoFolder, lProperty)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Este metodo desabilita a edicao de todos os controles do folder do objeto MsMGet ativo. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  					 
oEnch1:Disable()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com campos que podem ser alterados                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAltRGW1 := aClone(aCpoRGW1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com dados da tela de alteracao de dados ferias e 13o            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O primeiro painel com os dados do funcionario nao podem ser alterados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel1:lReadOnly := .T.

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CarPanel2  ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarPanel2(aObj3Size, cAlias, nReg, nOpcX)
Local nTop     := aObj3Size[1,1]
Local nLeft    := aObj3Size[1,2]
Local nWidth   := aObj3Size[1,3]
Local nHeightP := aObj3Size[2,4]
Local nHeightG := aObj3Size[1,4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta painel na aba 2                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel2 := TPanel():New(nTop, nLeft, '', oFolder:aDialogs[2],, .T., .T.,,, nWidth, nHeightP, .F., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta grid no painel 2                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowRGW2 := BrGetDDB():New(nTop, nLeft, nWidth-5, nHeightG,,,, oPanel2,,,,,,,,,,,, .F., 'RGW', .T.,, .F.)
oBrowRGW2:bDelOk	:= {||.T.}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui os campos a tabela da aba - Dados de ferias ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
oBrowRGW2:AddColumn(TCColumn():New(TitSX3("RGW_DTINI" )[1]		, {||RGW->RGW_DTINI}	,PESQPICT("RGW","RGW_DTINI"		),,,'LEFT' ,TAMSX3("RGW_DTINI"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW2:AddColumn(TCColumn():New(TitSX3("RGW_DTFIM" )[1]		, {||RGW->RGW_DTFIM}	,PESQPICT("RGW","RGW_DTFIM"		),,,'LEFT' ,TAMSX3("RGW_DTFIM"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW2:AddColumn(TCColumn():New(TitSX3("RGW_QUIT"  )[1]		, {||RGW->RGW_QUIT}		,PESQPICT("RGW","RGW_QUIT" 		),,,'LEFT' ,TAMSX3("RGW_QUIT"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW2:AddColumn(TCColumn():New(TitSX3("RGW_FALT"  )[1]		, {||RGW->RGW_FALT}		,PESQPICT("RGW","RGW_FALT" 		),,,'RIGHT',TAMSX3("RGW_FALT"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW2:AddColumn(TCColumn():New(TitSX3("RGW_ALT"   )[1]		, {||RGW->RGW_ALT}		,PESQPICT("RGW","RGW_ALT"  		),,,'RIGHT',TAMSX3("RGW_ALT"	)[1],.F.,.F.,,,,.F.,))
oBrowRGW2:AddColumn(TCColumn():New(""							, 						,								 ,,,'LEFT',							,.F.,.F.,,,,.F.,))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega para memoria varievais dos campos RGW   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
aCpoRGW2 := {"RGW_TPREG","RGW_DTINI","RGW_DTFIM","RGW_QUIT","RGW_FALT","RGW_ALT"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com campos que podem ser alterados                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAltRGW2 := {"RGW_DTINI" , "RGW_DTFIM" , "RGW_QUIT"  , "RGW_FALT"  }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Oculta os painel                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel2:Hide()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao incluir                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButInc2 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+10,04, {||GPEM601UPD(2, nReg, nOpcX, .T., .F.)}, oPanel2, .T., STR0010+" "+STR0004 )//"Incluir dados de Férias"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao alterar                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButAlt2 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+50,11, {||GPEM601UPD(2, nReg, nOpcX, .F., .F.)}, oPanel2, .T., STR0011+" "+STR0004, {||If(!RGW->(EoF()) .And. !RGW->(BoF()), .T., .F.)})//"Editar dados de Férias"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao delecao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButDel2 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+90,03, {||GPEM601Del(2, nReg, nOpcX, .F., .F.)}, oPanel2, .T., STR0012+" "+STR0004, {||If(!RGW->(EoF()) .And. !RGW->(BoF()), .T., .F.)})//"Excluir dados de Férias"

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CarPanel3  ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarPanel3(aObj3Size, cAlias, nReg, nOpcX)
Local nTop     := aObj3Size[1,1]
Local nLeft    := aObj3Size[1,2]
Local nWidth   := aObj3Size[1,3]
Local nHeightP := aObj3Size[2,4]
Local nHeightG := aObj3Size[1,4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta painel na aba 3                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel3 := TPanel():New(nTop, nLeft, '', oFolder:aDialogs[3],, .T., .T.,,,nWidth, nHeightP, .F., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta grid no painel 3                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowRGW3 := BrGetDDB():New(nTop, nLeft, nWidth-5, nHeightG,,,, oPanel3,,,,,,,,,,,, .F., 'RGW', .T.,, .F.)
oBrowRGW3:bDelOk	:= {||.T.}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui os campos a tabela da aba - Dados de 13o    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega para memoria varievais dos campos RGW   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
aCpoRGW3 := {	"RGW_TPREG","RGW_DTINI","RGW_QUIT","RGW_VALP13","RGW_M01","RGW_M02","RGW_M03",;
				"RGW_M04","RGW_M05","RGW_M06","RGW_M07","RGW_M08","RGW_M09","RGW_M10","RGW_M11","RGW_M12","RGW_ALT"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com campos que podem ser alterados                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAltRGW3 := {"RGW_DTINI" , "RGW_QUIT"  , "RGW_VALP13", "RGW_M01"  , "RGW_M02"   , "RGW_M03"   , "RGW_M04" , "RGW_M05"  , "RGW_M06"   , "RGW_M07" , "RGW_M08"   , "RGW_M09"   , "RGW_M10"   , "RGW_M11"  , "RGW_M12"   }							

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Oculta os painel                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel3:Hide()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao incluir                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButInc3 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+10,04, {||GPEM601UPD(3, nReg, nOpcX, .T., .F.)}, oPanel3, .T., STR0010+" "+STR0005 )//"Incluir dados de 13º"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao alterar                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButAlt3 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+50,11, {||GPEM601UPD(3, nReg, nOpcX, .F., .F.)}, oPanel3, .T., STR0011+" "+STR0005, {||If(!RGW->(EoF()) .And. !RGW->(BoF()), .T., .F.)})//"Editar dados de 13º"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao delecao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButDel3 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+90,03, {||GPEM601Del(3, nReg, nOpcX, .F., .F.)}, oPanel3, .T., STR0012+" "+STR0005, {||If(!RGW->(EoF()) .And. !RGW->(BoF()), .T., .F.)})//"Excluir dados de 13º"

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CarPanel4  ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarPanel4(aObj3Size, cAlias, nReg, nOpcX)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta painel na aba 4                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel4 	:= TPanel():New(aObj3Size[1,1], aObj3Size[1,2],'',oFolder:aDialogs[4],, .T., .T.,, ,aObj3Size[1,3], aObj3Size[2,4],.F.,.F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta grid no painel 4                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowRGX	:= BrGetDDB():New(aObj3Size[1,1],aObj3Size[1,2],aObj3Size[1,3]-5,aObj3Size[1,4],,,,oPanel4,,,,,,,,,,,,.F.,'RGX',.T.,,.F.,,, )
oBrowRGX:bDelOk		:= {||.T.}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui os campos a tabela da aba - Dados financeiros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega para memoria varievais dos campos RGX   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
CarCampos("RGX", @aCpoRGX)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com dados da tela de alteracao de dados financeiro              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aPadraoRGX,{"RGX_FILIAL", xFilial("RGX",TRB->RA_FILIAL) 	})
aAdd(aPadraoRGX,{"RGX_MAT"	 , TRB->RA_MAT    					})
aAdd(aPadraoRGX,{"RGX_HOMOL" , TRB->RG_DATAHOM					})
aAdd(aPadraoRGX,{"RGX_TPRESC", "1"            					})//Tipo de Rescisão
aAdd(aPadraoRGX,{"RGX_ALT"	 , RGX->RGX_ALT						})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com campos que podem ser alterados                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAltRGX :={"RGX_TPREG","RGX_MESANO","RGX_FORSAL","RGX_TPSAL", "RGX_CODRUB","RGX_VALRUB","RGX_PROD",  "RGX_VALBC", "RGX_QTDPRO","RGX_PERC",  "RGX_QTDHOR","RGX_SALLIQ","RGX_TRIBUT","RGX_INTBC", "RGX_QTDDSR"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Oculta os painel                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel4:Hide()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao incluir                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButInc4 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+10,04, {||GPEM601UPD(4, nReg, nOpcX, .T., .F.)}, oPanel4, .T., STR0010+" "+STR0006 )//"Incluir dados Financeiros"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao alterar                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButAlt4 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+50,11, {||GPEM601UPD(4, nReg, nOpcX, .F., .F.)}, oPanel4, .T., STR0011+" "+STR0006, {||If(!RGX->(EoF()) .And. !RGX->(BoF()), .T., .F.)})//"Editar dados Financeiros"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao delecao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButDel4 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+90,03, {||GPEM601Del(4, nReg, nOpcX, .F., .F.)}, oPanel4, .T., STR0012+" "+STR0005, {||If(!RGX->(EoF()) .And. !RGX->(BoF()), .T., .F.)})//"Excluir dados Financeiros"

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CarPanel5  ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarPanel5(aObj3Size, cAlias, nReg, nOpcX)
Local nTop     := aObj3Size[1,1]
Local nLeft    := aObj3Size[1,2]
Local nWidth   := aObj3Size[1,3]
Local nHeightP := aObj3Size[2,4]
Local nHeightG := aObj3Size[1,4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta painel na aba 5                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel5 := TPanel():New(nTop, nLeft,'',oFolder:aDialogs[5],, .T., .T.,,, nWidth, nHeightP, .F., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta grid no painel 5                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowRGZ := BrGetDDB():New(nTop, nLeft, nWidth-5, nHeightG,,,, oPanel5,,,,,,,,,,,, .F., 'RGZ', .T.,, .F.)
oBrowRGZ:bDelOk		:= {||.T.}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui os campos a tabela da aba - Movimentacoes   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
oBrowRGZ:AddColumn(TCColumn():New(TitSX3("RGZ_DTMVTO")[1]+"   ",{||RGZ->RGZ_DTMVTO}		,PESQPICT("RGZ","RGZ_DTMVTO"	),,,'LEFT' ,TAMSX3("RGZ_DTMVTO"	)[1],.F.,.F.,,,,.F.,))
oBrowRGZ:AddColumn(TCColumn():New(TitSX3("RGZ_MOTIVO")[1]+"   ",{||RGZ->RGZ_MOTIVO}		,PESQPICT("RGZ","RGZ_MOTIVO"	),,,'LEFT' ,TAMSX3("RGZ_MOTIVO"	)[1],.F.,.F.,,,,.F.,))
oBrowRGZ:AddColumn(TCColumn():New(TitSX3("RGZ_ALT"   )[1]+"   ",{||RGZ->RGZ_ALT   }		,PESQPICT("RGZ","RGZ_ALT"   	),,,'LEFT' ,TAMSX3("RGZ_ALT"   	)[1],.F.,.F.,,,,.F.,))
oBrowRGZ:AddColumn(TCColumn():New(""						   ,						,								 ,,,'LEFT' ,						,.F.,.F.,,,,.F.,))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega para memoria varievais dos campos RGZ   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
CarCampos("RGZ", @aCpoRGZ)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com campos que podem ser alterados                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAltRGZ :={"RGZ_MOTIVO","RGZ_DTMVTO"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com dados da tela de alteracao de movimentacao                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aPadraoRGZ,{"RGZ_FILIAL", xFilial("RGZ",TRB->RA_FILIAL) 	})
aAdd(aPadraoRGZ,{"RGZ_MAT"	 , TRB->RA_MAT    					})
aAdd(aPadraoRGZ,{"RGZ_HOMOL" , TRB->RG_DATAHOM					})
aAdd(aPadraoRGZ,{"RGZ_TPRESC", "1"            					})//Tipo de Rescisão
aAdd(aPadraoRGZ,{"RGZ_ALT"	 , RGZ->RGZ_ALT						})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Oculta os painel                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel5:Hide()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao incluir                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButInc5 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+10,04, {||GPEM601UPD(5, nReg, nOpcX, .T., .F.)}, oPanel5, .T., STR0010+" "+STR0007 )//"Incluir Movimentações"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao alterar                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButAlt5 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+50,11, {||GPEM601UPD(5, nReg, nOpcX, .F., .F.)}, oPanel5, .T., STR0011+" "+STR0007, {||If(!RGZ->(EoF()) .And. !RGZ->(BoF()), .T., .F.)})//"Editar Movimentações"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao delecao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButDel5 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+90,03, {||GPEM601Del(5, nReg, nOpcX, .F., .F.)}, oPanel5, .T., STR0012+" "+STR0006, {||If(!RGZ->(EoF()) .And. !RGZ->(BoF()), .T., .F.)})//"Excluir Movimentações"

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CarPanel6  ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarPanel6(aObj3Size, cAlias, nReg, nOpcX)
Local nTop     := aObj3Size[1,1]
Local nLeft    := aObj3Size[1,2]
Local nWidth   := aObj3Size[1,3]
Local nHeightP := aObj3Size[2,4]
Local nHeightG := aObj3Size[1,4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta painel na aba 6                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel6 := TPanel():New(nTop, nLeft, '', oFolder:aDialogs[6],, .T., .T.,,, nWidth, nHeightP,.F.,.F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta grid no painel 6                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowRGY := BrGetDDB():New(nTop, nLeft, nWidth-5, nHeightG,,,, oPanel6,,,,,,,,,,,, .F., 'RGY', .T.,, .F. )           
oBrowRGY:bDelOk	:= {||.T.}	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui os campos a tabela da aba - Dados descontos da Rescisao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
oBrowRGY:AddColumn(TCColumn():New(TitSX3("RGY_TPREG" )[1]+"   ",{||RGY->RGY_TPREG}		,PESQPICT("RGY","RGY_TPREG"		),,,'LEFT' ,TAMSX3("RGY_TPREG"	)[1],.F.,.F.,,,,.F.,))
oBrowRGY:AddColumn(TCColumn():New(TitSX3("RGY_CODIGO")[1]+"   ",{||RGY->RGY_CODIGO}		,PESQPICT("RGY","RGY_CODIGO"	),,,'LEFT' ,TAMSX3("RGY_CODIGO"	)[1],.F.,.F.,,,,.F.,))
oBrowRGY:AddColumn(TCColumn():New(TitSX3("RGY_VALHOR")[1]+"   ",{||RGY->RGY_VALHOR}		,PESQPICT("RGY","RGY_VALHOR"	),,,'RIGHT',TAMSX3("RGY_VALHOR"	)[1],.F.,.F.,,,,.F.,))
oBrowRGY:AddColumn(TCColumn():New(TitSX3("RGY_TRIBUT")[1]+"   ",{||RGY->RGY_TRIBUT}		,PESQPICT("RGY","RGY_TRIBUT"	),,,'LEFT' ,TAMSX3("RGY_TRIBUT"	)[1],.F.,.F.,,,,.F.,))
oBrowRGY:AddColumn(TCColumn():New(TitSX3("RGY_ALT"   )[1]+"   ",{||RGY->RGY_ALT   }		,PESQPICT("RGY","RGY_ALT"   	),,,'LEFT' ,TAMSX3("RGY_ALT"   	)[1],.F.,.F.,,,,.F.,))
oBrowRGY:AddColumn(TCColumn():New(""						   ,						,								 ,,,'LEFT' ,						,.F.,.F.,,,,.F.,))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega para memoria varievais dos campos RGY   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
CarCampos("RGY", @aCpoRGY)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com campos que podem ser alterados                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAltRGY :={"RGY_TPREG","RGY_CODIGO","RGY_VALHOR","RGY_TRIBUT"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com dados da tela de alteracao de rescisao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aPadraoRGY,{"RGY_FILIAL", xFilial("RGY",TRB->RA_FILIAL) 	})
aAdd(aPadraoRGY,{"RGY_MAT"	 , TRB->RA_MAT    					})
aAdd(aPadraoRGY,{"RGY_HOMOL" , TRB->RG_DATAHOM					})
aAdd(aPadraoRGY,{"RGY_TPRESC", "1"            					})//Tipo de Rescisão
aAdd(aPadraoRGY,{"RGY_ALT"	 , RGY->RGY_ALT						})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Oculta os painel                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel6:Hide()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao incluir                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButInc6 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+10,04, {||GPEM601UPD(6, nReg, nOpcX, .T., .F.)}, oPanel6, .T., STR0010+" "+STR0008 )//"Incluir descontos da Rescisão"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao alterar                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButAlt6 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+50,11, {||GPEM601UPD(6, nReg, nOpcX, .F., .F.)}, oPanel6, .T., STR0011+" "+STR0008, {||If(!RGY->(EoF()) .And. !RGY->(BoF()), .T., .F.)})//"Editar descontos da Rescisão"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao delecao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSButDel6 := SButton():New( aObj3Size[2,1]+10, aObj3Size[2,2]+90,03, {||GPEM601Del(6, nReg, nOpcX, .F., .F.)}, oPanel6, .T., STR0012+" "+STR0007, {||If(!RGY->(EoF()) .And. !RGY->(BoF()), .T., .F.)})//"Excluir descontos da Rescisão"

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CarCampos  ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601TOK ³ Autor ³ Wagner Montenegro  ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função de Validação da Enchoice Homolognet		  		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601TOK()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  												       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida item de ferias - aba 2                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	nRegRGW:=RGW->(Recno())
	If RGW->(dbSeek(xFilial("RGW",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+"1"+DtoS(M->RGW_DTINI)))
		If !lNovo .AND. RGW->(Recno())<>nRegRGW .or. lNovo
			lRet:=.F.
			MsgAlert(STR0013)//"Periodo aquisitivo já cadastrado!"
		EndIf	
	EndIf
	RGW->(dbGoTo(nRegRGW))
	If lRet
		oDlgAlter:End()
	EndIf	
ElseIf nFolder == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida item de 13o - aba 3                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	nRegRGW:=RGW->(Recno())
	If RGW->(dbSeek(xFilial("RGW",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+"2"+DtoS(M->RGW_DTINI))) 
		If !lNovo .AND. RGW->(Recno())<>nRegRGW .or. lNovo
			lRet:=.F.
			MsgAlert(STR0014)//"Exercicio já cadastrado!"
		EndIf
	EndIf
	RGW->(dbGoTo(nRegRGW))
	If lRet
		oDlgAlter:End()
	EndIf	
ElseIf nFolder == 4
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida item de dados financeiro - aba 4             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
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
	   		MsgAlert(STR0015+cRetMens+STR0016)//"Os campos: " //" são de preenchimento obrigatório!"
		Else 
			MsgAlert(STR0017+cRetMens+STR0018)//"O campo " //" é de preenchimento obrigatório!"
		Endif
	Else
		nRegRGX:=RGX->(Recno())
		If RGX->(dbSeek(xFilial("RGX",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+M->RGX_MESANO+M->RGX_TPREG+M->RGX_CODRUB)) 
			If !lNovo .and.  RGX->(Recno())<>nRegRGX .or. lNovo
				lRet:=.F.
				MsgAlert(STR0019)//"O Tipo e Código de Rubrica informados para o período já existe na base de dados!"
			EndIf
		EndIf
		RGX->(dbGoTo(nRegRGX))
		If lRet
			oDlgAlter:End()
		EndIf
	Endif
ElseIf nFolder == 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida item de movimentacao - aba 5                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	nRegRGZ:=RGZ->(Recno())
	If RGZ->(dbSeek(xFilial("RGZ",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+M->RGZ_MOTIVO+DtoS(M->RGZ_DTMVTO))) 
		If !lNovo .And. RGZ->(Recno()) <> nRegRGZ .Or. lNovo
			lRet:=.F.
			MsgAlert(STR0020)//"Movimentação já informada!"
		EndIf
	EndIf
	RGZ->(dbGoTo(nRegRGZ))
	If lRet
		oDlgAlter:End()
	EndIf		
ElseIf nFolder == 6
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida item de rescisao - aba 6                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	nRegRGY:=RGY->(Recno())
	If RGY->(dbSeek(xFilial("RGY",TRB->RA_FILIAL)+TRB->RA_MAT+'1'+DtoS(TRB->RG_DATAHOM)+M->RGY_CODIGO))
		If !lNovo .AND. RGY->(Recno())<>nRegRGY .Or. lNovo
			lRet:=.F.
			MsgAlert(STR0021)//"Desconto já informado!"
		EndIf	
	EndIf
	RGY->(dbGoTo(nRegRGY))
	If lRet
		oDlgAlter:End()
	EndIf
EndIf 

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601FLD ³ Autor ³ Wagner Montenegro  ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função de Controle dos Folders de Edição Homolognet		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601FLD()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM601FLD(nFldDes, nFldAtu, nReg, nOpcX, oDlg, oFolder)
Local lRet		:= .T.
Local nAlias	:= 0
Local nX		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for visualizacao oculta os botoes                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra tabelas                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
RGX->(Eval( bFiltraRGX ))
RGZ->(Eval( bFiltraRGZ ))
RGY->(Eval( bFiltraRGY ))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Oculta painel de acordo com o clique na aba         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe o painel 1: Dados Iniciais                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nX := 1 to Len(aPadraoRGW)
	    aPadraoRGW[nX,2] := RGW->&(aPadraoRGW[nX,1]) 
	Next
  	oPanel1:Show()	
Elseif nFldDes == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe o painel 2: Dados de ferias                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cCondRGW := "RGW_FILIAL=='"+xFilial('RGW',TRB->RA_FILIAL)+"' .AND. RGW_MAT==TRB->RA_MAT .AND. RGW_TPRESC=='1' .AND. RGW_HOMOL==TRB->RG_DATAHOM .AND. RGW_TPREG=='1'" 
	RGW->(Eval( bFiltraRGW))
	oBrowRGW2:GoTop()
  	oPanel2:Show()
Elseif nFldDes == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe o painel 3: Dados de 13o                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cCondRGW := "RGW_FILIAL=='"+xFilial('RGW',TRB->RA_FILIAL)+"' .AND. RGW_MAT==TRB->RA_MAT .AND. RGW_TPRESC=='1' .AND. RGW_HOMOL==TRB->RG_DATAHOM .AND. RGW_TPREG=='2'" 
	RGW->(Eval( bFiltraRGW))
	oBrowRGW3:GoTop()
  	oPanel3:Show()                
Elseif nFldDes == 4
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe o painel 4: Dados financeiro                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
  	oPanel4:Show()   
Elseif nFldDes == 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe o painel 5: Dados movimentacoes               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
  	oPanel5:Show()                
Elseif nFldDes == 6
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe o painel 6: Descontos da rescisao             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
  	oPanel6:Show()   
Endif
oFolder:nOption

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601UPD ³ Autor ³ Wagner Montenegro  ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função de Edição e Visualização Homolognet	       		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601UPD()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega em array posicao dos objetos em tela        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
aAdvSize        := MsAdvSize(,.T.,370)
aInfoAdvSize    := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 020 , .T. , .F.      } )
aAdd( aObjCoords , { 000 , 100 , .T. , .T., .T. } )
aObjSize    := MsObjSize( aInfoAdvSize , aObjCoords ) // Tratamento odlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega em array posicao dos objetos em tela        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
aAdv2Size     := aClone(aObjSize[2])
aInfo2AdvSize := { 0,0 , aAdv2Size[4] , aAdv2Size[3] , 3 , 5 }
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta janela de manutencao                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgAlter := tDialog():New(aAdvSize[7], 0, aAdvSize[6], aAdvSize[5], STR0004+" - "+If(lNovo,STR0010,STR0011),,,,,,,,, .T.) //"Dados de Férias" //"Inclusão","Alteração"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta objeto de abas abaixo do cabecalho         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
TelaCabec(aObjSize, @oDlgAlter)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega alias, memoria e array de campos que podem ser alterados conforme aba posicionada ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicao dos MsMGet's               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPos := {aObj2Size[1,1]+22, aObj2Size[1,2]+2.5, aObj2Size[1,4]+31, aObj2Size[1,3]+10}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta MsMGet                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnchAlter := MsMGet():New(cAliasAlter, nReg, nOpcX,,,, aAlteracao, aPos, aAlteracao, nModelo, ,, , oDlgAlter, lF3, lMemoria, lColumn, caTela, lNoFolder, lProperty)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre janela de alteracao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgAlter:Activate(,,, .T.,,, ;
					EnchoiceBar(oDlgAlter, {|| IIF(GPEM601TOk(nFolder, lNovo), ;
					IIF(GPEM601GRV(aAlteracao, nOpcX, nFolder, lNovo), nOpcao := 1, ;
					{||nOpcao:=0, oDlgAlter:End()}),nOpcao:=0)},	{||oDlgAlter:End()},,aButtons) ;
				   )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Destrava a tabela confirma a alteracao          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If nOpcao == 0
	&(cAliasAlter)->(MsUnLock())
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601GRV ³ Autor ³ Wagner Montenegro  ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função de Gravação Alteração/Inclusão Homolognet	           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601GRV()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM601GRV(aCpos, nOpcX, nFolder, lNovo)
Local aArea 	:= GetArea()
Local nX		:= 0
Local aAlterTab	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com campos alterado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a gravacao                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN TRANSACTION
	RecLock( aHom[nFolder], lNovo )

	If lNovo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclusao                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601DEL ³ Autor ³ Wagner Montenegro  ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função de Exclusão dos dados de Tabelas Homolognet	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601DEL()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL 											           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
	If apMsgNoYes(STR0022+TRB->RA_MAT+STR0023) //"Confirma a exclusão dos registros do Homolognet para a Matricula[" //"]?"
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
	If apMsgNoYes(STR0024)//"Confirma a exclusão?"
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MenuDef  ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados		  ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef() 
Local aRotina := {	{ STR0026, "GPEM601MAN('TRB',TRB->(Recno()),4)"	,0,4,,.F.},;	// "Manutenção"
					{ STR0027, "GPEM601MAN('TRB',TRB->(Recno()),2)"	,0,2,,.F.},;	// "Visualização"
					{ STR0028, "GPEM601Del()"						,0,4,,.F.},;	// "Exclusão"
					{ STR0029, "GPEM601LGD('TRB',TRB->(Recno()))"  	,0,3,,.F.}	}	// "Legenda"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ GPEM601LGD ³ Autor ³ Wagner Montenegro	³ Data ³ 30.10.2010	³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±     
±±³Descri‡…o ³ Exibe a legenda Homolognet                   			    ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   	³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ GPEM601LGD()												  	³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Brasil                   					   				³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM601LGD(cAlias, nReg)
Local aLegenda	:= {	{"BR_VERDE"		, STR0030	},;		// 01 - "XML não gerado"
						{"BR_VERMELHO"	, STR0031	} }		// 02 - "XML Gerado"

Local uRetorno	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada direta da funcao onde nao passa, via menu Recno eh passado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nReg == Nil	
	uRetorno := {}
	Aadd(uRetorno, { 'EMPTY(RGW_NUMID)' , aLegenda[1][1] } )
	Aadd(uRetorno, { '!EMPTY(RGW_NUMID)', aLegenda[2][1] } )
Else
	BrwLegenda(STR0001, STR0029, aLegenda) //"Homolognet", "Legenda"
Endif  

Return(uRetorno)
					
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601RGY ³ Autor ³ Wagner Montenegro  ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação usada tambem na clausula VALID no SX3             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601RGY()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
			MsgAlert(STR0032)//"Registro de Desconto já informado!"
		Endif
	Else
		If SRV->( dbSeek( xFilial("SRV", TRB->RA_FILIAL)+cCodDescto))
	      If SRV->RV_TIPOCOD <> '2'
	         lRet:=.F.
	         MsgAlert(STR0033)//"Este código não corresponde a Desconto!"
	      Endif
	   Endif   
	Endif
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclusao de novos descontos - SEMPRE Verificar as funcoes GPEM601RGY; GPEM601V04 e Registro8 do fonte GPEM602 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(cCodDescto $ "A01/A02/A03/A04/A05/A06/A07/A08/A09/A10/A11/A12/A13/A14/A15")
		lRet	:=	.F.
		MsgAlert(STR0034)//"Registro não encontrado!"
	Else
		nRegRGY := RGY->(Recno()) 
		RGY->(dbSetOrder(1))
		If RGY->( dbSeek( xFilial("RGY",TRB->RA_FILIAL)+cMat+cTpResc+DTOS(dHomol)+cCodDescto ) )
			If !lNovo2 .And. RGY->(Recno()) <> nRegRGY .Or. lNovo2
				lRet := .F.
				MsgAlert(STR0032)//"Registro de Desconto já informado!"
			Endif
		Endif
	Endif
Endif

RestArea(aAreaSRV)		
RestArea(aAreaRGY)
RestArea(aAreaAtu)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601RGZ ³ Autor ³ Wagner Montenegro  ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao usada tambem na clausula VALID no SX3             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601RGZ()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM601RGZ(cFilRGZ, cMat, cTpResc, dHomol, cMotivo, dMvto)
Local aAreaAtu	:= GetArea()
Local aAreaRGZ	:= RGZ->(GetArea())
Local lRet		:= .T.
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de novos afastamentos - Q7 e Z20 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(cMotivo) $ "M/N1/N2/O1/O2/O3/P1/P2/P3/Q1/Q2/Q3/Q4/Q5/Q6/Q7/R/S2/S3/U1/U3/W/X1/X2/X3/Y/Z1/Z2/Z3/Z4/Z6/Z7/Z8/Z9/Z10/Z11/Z12/Z13/Z14/Z15/Z16/Z17/Z18/Z19/Z20"
	If RGZ->(dbSeek(  xFilial("RGX",TRB->RA_FILIAL)+cMat+cTpResc+Dtos(dHomol)+cMotivo+Dtos(dMvto) ))
   		lRet := .F.
		MsgAlert( STR0035 )		// "O Código de Movimentação informado já existe para esta data!"
	Endif   
Else
	lRet := .F.
	MsgAlert( STR0036 )			// "Código de Movimentação não encontrado!"
Endif

RestArea(aAreaRGZ)
RestArea(aAreaAtu)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³M   - Mudança de regime estatutário                                                                                                                                                  ³
³N1  - Transf. empregado p/ outro estabelecimento da mesma empresa                                                                                                                    ³
³N2  - Transf. empregado p/ outra empresa que tenha assumido os encargos trab., sem que tenha havido rescisão de contrato de trabalho                                                 ³
³O1  - Afastamento temporário por motivo de acidente do trabalho, por período superior a 15 dias                                                                                      ³
³O2  - Novo afastamento temporário em decorrência do mesmo acidente do trabalho                                                                                                       ³
³O3  - Afastamento temporário por motivo de acidente do trabalho, por período igual ou inferior a 15 dias                                                                             ³
³P1  - Afastamento temporário por motivo de doença, por período superior a 15 dias"                                                                                                   ³
³P2  - Novo afastamento temporário em decorrência da mesma doença, dentro de 60 dias contados da cessação do afastamento anterior"                                                    ³
³P3  - Afastamento temporário por motivo de doença, por período igual ou inferior a 15 dias                                                                                           ³
³Q1  - Afastamento temporário por motivo de licença-maternidade (120 dias)                                                                                                            ³
³Q2  - Prorrogação do afastamento temporário por motivo de licença-maternidade                                                                                                        ³
³Q3  - Afastamento temporário por motivo de aborto não criminoso                                                                                                                      ³
³Q4  - Afastamento temporário por motivo de licença-maternidade decorrente de adoção ou guarda judicial de criança até 1 (um) ano de idade (120 dias)                                 ³
³Q5  - Afastamento temporário por motivo de licença-maternidade decorrente de adoção ou guarda judicial de criança a partir de 1 (um) ano até 4 (quatro) anos de idade (60 dias)      ³
³Q6  - Afastamento temporário por motivo de licença-maternidade decorrente de adoção ou guarda judicial de criança a partir de 4 (quatro) anos até 8 (oito) anos de idade (30 dias)   ³
³Q7  - Prorrogação da duração da licença-maternidade - Programa Empresa Cidadã - Lei no. 11.770/2008                                                                                  ³
³R   - Afastamento temporário para prestar serviço militar                                                                                                                            ³
³S2  - Falecimento                                                                                                                                                                    ³ 
³S3  - Falecimento motivado por acidente de trabalho                                                                                                                                  ³
³U1  - Aposentadoria por tempo de contribuição ou idade sem continuidade de vínculo empregatício                                                                                      ³
³U3  - Aposentadoria por invalidez                                                                                                                                                    ³
³W   - Afastamento temporário para exercício de mandato sindical                                                                                                                      ³
³X1  - Licença com percepção de salário                                                                                                                                               ³
³X2  - Licença sem percepção de salário                                                                                                                                               ³
³X3  - Afastamento por suspensão do contrato de trabalho prevista no art. 476-A da CLT                                                                                                ³
³Y   - Outros motivos de afastamento temporário                                                                                                                                       ³
³Z1  - Retorno de afastamento temporário por motivo de licença-maternidade, informado pela movimentação Q1                                                                            ³
³Z2  - Retorno de afastamento temporário por motivo de acidente do trabalho, por período superior a 15 dias, informado pela movimentação O1                                           ³
³Z3  - Retorno de novo afastamento temporário em decorrência do mesmo acidente do trabalho, informado pela movimentação O2                                                            ³
³Z4  - Retorno do afastamento temporário para prestar serviço militar obrigatório, informado pela movimentação R                                                                      ³
³Z6  - Retorno de afastamento temporário por motivo de acidente do trabalho, por período igual ou inferior a 15 dias, informado pela movimentação O3                                  ³
³Z7  - Retorno de afastamento temporário por motivo de doença, por período superior a 15 dias, informado pela movimentação P1                                                         ³
³Z8  - Retorno de novo afastamento temporário em decorrência da mesma doença, dentro de 60 dias contados da cessação do afastamento anterior, informado pela movimentação P2          ³
³Z9  - Retorno de licença com percepção de salário, informado pela movimentação X1                                                                                                    ³
³Z10 - Retorno de licença sem percepção de salário, informado pela movimentação X2                                                                                                    ³
³Z11 - Retorno da aposentadoria por invalidez, informado pela movimentação U3                                                                                                         ³
³Z12 - Retorno do afastamento temporário para exercício de mandato sindical, informado pela movimentação W                                                                            ³
³Z13 - Retorno do afastamento temporário por motivo de aborto não criminoso, informado pela movimentação Q3                                                                           ³
³Z14 - Retorno da prorrogação do afastamento temporário por motivo de licençamaternidade, informado pela movimentação Q2                                                              ³
³Z15 - Retorno de afastamento temporário por motivo de licença-maternidade, informado pela movimentação Q4                                                                            ³
³Z16 - Retorno de afastamento temporário por motivo de licença-maternidade, informado pela movimentação Q5                                                                            ³
³Z17 - Retorno de afastamento temporário por motivo de licença-maternidade, informado pela movimentação Q6                                                                            ³
³Z18 - Retorno de afastamento temporário por motivo de doença, por período igual ou inferior a 15 dias, informado pela movimentação P3                                                ³
³Z19 - Retorno do afastamento por suspensão do contrato de trabalho prevista no art. 476-A da CLT, informado pela movimentação X3                                                     ³
³Z20 - Retorno de afastamento temporário por motivo de licença-maternidade (Programa Empresa Cidadã) - Q7                                                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601V01 ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao usada tambem na clausula VALID no SX3              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601V01()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM601V01()
Local lRet := .F.

If M->RGX_TPREG == "1" .And. !(M->RGX_CODRUB $ "003/004/012/013/014/015/016/018/019/035") .Or. M->RGX_TPREG == "2"
	lRet := .T.
Endif

Return( lRet )
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601V02 ³ Autor ³ Wagner Montenegro  ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao usada tambem na clausula VALID no SX3             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601V02(                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  												       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM601V02()
Local lRet := .F.

IF M->RGX_TPREG == '1' .And. M->RGX_CODRUB $ '004/012/013/014/015/016/018/019'
	lRet := .T.
Endif

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601V03 ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao usada tambem na clausula VALID no SX3              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601V03()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  												        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM601V03()
Local lRet := .F.

IF M->RGX_TPREG == '1' .And. M->RGX_CODRUB $ '004/012/015/016/035' .Or. M->RGX_TPREG == '1' .And. M->RGX_CODRUB == '005' .And. M->RGX_TPSAL == '1'
	lRet := .T.
ENDIF

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601V04 ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao usada tambem na clausula VALID no SX3              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601V04()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclusao de novos descontos - A14 e A15 - SEMPRE Verificar as funcoes GPEM601RGY; GPEM601V04 e a Registro8 do fonte GPEM602 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSit :={	;
				{"xFilial('RCC')", "S020", "", "", "001", "A01Adiantamento Salarial                                 "},;
				{"xFilial('RCC')", "S020", "", "", "002", "A02Adiantamento 13º Salário                              "},;
				{"xFilial('RCC')", "S020", "", "", "003", "A03Faltas injust. no mês/rescisão acresc. do DSR corresp."},;  
				{"xFilial('RCC')", "S020", "", "", "004", "A04Valor total Gasto com Vale Transporte                 "},;
				{"xFilial('RCC')", "S020", "", "", "005", "A05Desconto Vale Alimentação                             "},;
				{"xFilial('RCC')", "S020", "", "", "006", "A06Reembolso de Vale Transporte                          "},;
				{"xFilial('RCC')", "S020", "", "", "007", "A07Reembolso de Vale Alimentação                         "},;
				{"xFilial('RCC')", "S020", "", "", "008", "A08Saldo devedor de empréstimo consignado                "},;
				{"xFilial('RCC')", "S020", "", "", "009", "A09Indenização Art 480 CLT                               "},;  
				{"xFilial('RCC')", "S020", "", "", "010", "A10Contribuições para previdência privada                "},;
				{"xFilial('RCC')", "S020", "", "", "011", "A11Contribuições para FAPI                               "},;
				{"xFilial('RCC')", "S020", "", "", "012", "A12Outras deduções para base de cálculo IRRF             "},;
				{"xFilial('RCC')", "S020", "", "", "013", "A13Contribuição sindical laboral Art 580 CLT             "},;
				{"xFilial('RCC')", "S020", "", "", "014", "A14Compensação Dias Salário Férias Mês Afastamento	    "},;
				{"xFilial('RCC')", "S020", "", "", "015", "A15Complementação IRRF Rendimento Mês Quitação		    "};
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
		MsgAlert(STR0034)//"Registro não encontrado!"
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
	   MsgAlert(STR0037) //"Código de Rubrica não localizado no Cadastro de Verbas!"
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM601PSQ ³ Autor ³ Wagner Montenegro   ³ Data ³ 30/10/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para pesquisa no TRB						            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM601PSQ()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASIL  													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega posicao dos objetos em tela                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdvSize        := MsAdvSize(,.T.,370)
aInfoAdvSize    := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )
aObjSize        := MsObjSize( aInfoAdvSize , aObjCoords )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta janela de Pesquisa                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgPsq := tDialog():New(aAdvSize[7], 0, aAdvSize[6]*0.40, aAdvSize[5], STR0025,,,,,,,,, .T.) //"Pesquisa"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta grupo da janela de pesquisa                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGroupFil  := TGroup():Create( oDlgPsq, aObjSize[1][1], aObjSize[1][4] * 0.185  , aObjSize[1][3], aObjSize[1][4] * 0.18, TitSX3("RA_FILIAL")[1]   ,,, .T.) // "Filial:"
oGroupMat  := TGroup():Create( oDlgPsq, aObjSize[1][1], aObjSize[1][2]	        , aObjSize[1][3], aObjSize[1][4]       , TitSX3("RA_MAT")[1]      ,,, .T.) // "Matricula:" 
oGroupFil:oFont := oFont
oGroupMat:oFont := oFont 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta get da janela de pesquisa                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetFil:Create( oDlgPsq, {|| TamSx3("RA_FILIAL")[1]}, aObjSize[1,1] + 10, aObjSize[1,2] * 2.5, 030, 010,,,,, oFont,,, .T.)
oGetMat:Create( oDlgPsq, {|| TamSx3("RA_MAT")[1]}   , aObjSize[1,1] + 10, aObjSize[1,2] * 0,2, 060, 010,,,,, oFont,,, .T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta bloco de validacao da pesquisa             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bSet15 := {|| If(!Empty(cFilMat) .and. !Empty(cMat),If(TRB->(dbSeek(cFilMat+cMat)),oDlgPsq:End(),MsgAlert(STR0034)),MsgAlert(STR0038))}
bSet24 := {|| TRB->(dbGoTo(nRecOld)),oDlgPsq:End()}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre janela                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgPsq:Activate(,,, .T.,,, EnchoiceBar(oDlgPsq, bSet15, bSet24) )

Return(.T.)