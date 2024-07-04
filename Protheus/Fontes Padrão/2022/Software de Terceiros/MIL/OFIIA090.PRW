// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 06     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "ofiia090.ch"
#include "Protheus.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIIA090 ³ Autor ³ Emilton               ³ Data ³ 04/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao dos dados do VIG no arquivos VO6/VO7              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao montadora                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA090(cPreMar,nOpcx)

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004)   //Importacao da Tabela de Servicos
Private cCodMar  && Variavel criada para nao ter conflito com a segunda pergunte
Private lMsErroAuto
Private cMarcaGM := FG_MARCA("CHEVROLET",,.f.)
Private lAuto := .f.
Private lMarcaTodos := .t.
Private cSXENum
DBSelectArea("VO6")
DBSetOrder(1)
DBGoBottom()
cSXENum := VO6->VO6_SERINT
cSXENum = STRZERO(VAL(cSXENum)+1,6)
nOpcx := If( nOpcx # NIL, nOpcx, 3 )

If cPreMar # NIL
	lAuto := .t.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lAuto
	
	Pergunte("OFIMAR",.f.)
	
	MV_PAR01 := cPreMar
	
Else
	
	If !Pergunte("OFIMAR",.t.)
		Return
	EndIf

EndIf
            
cCodMar := MV_PAR01

DbSelectArea("VOS")
DbSetOrder(1)
DbSelectArea("VJ9")
DbSetOrder(1)
DbSelectArea("VV2")
DbSetOrder(1)
DbSelectArea("VO7")
DbSetOrder(1)
DbSelectArea("VO6")
DbSetOrder(2)
dbSelectArea("VE4")
dbSetOrder(1)
dbSeek( xFilial("VE4") + cCodMar )
                          
If cMarcaGM == cCodMar

	&& Levanta dados para o VIG da GM.
	Processa( {|| FS_IA090GM()} )
              
Else

	If lMarcaTodos
		DbSelectArea("VIG")
		DbSetOrder( 1 )
		cIndVIG := CriaTrab(Nil, .F.)
		cKeyVIG := IndexKey()
		IndRegua("VIG",cIndVIG,cKeyVIG,,"VIG_CODMAR == cCodMar",OemToAnsi(STR0004) )
	                    
		If lAuto
	   
			If nOpcx == 2
				IA090V(Alias(),VIG->(Recno()),nOpcx)
			ElseIf nOpcx == 3
				IA090I(Alias(),VIG->(Recno()),nOpcx)
			EndIf
			
		Else
			
			mBrowse( 6, 1,22,75,"VIG")
			
		EndIf
		
		DbSelectArea("VIG")
		RetIndex()
		
		#IFNDEF TOP
			If File(cIndVIG+OrdBagExt())
				fErase(cIndVIG+OrdBagExt())
			Endif
		#ENDIF

	EndIf
EndIf

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IA090I    ³ Autor ³ Emilton               ³ Data ³ 20/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a funcao de gravacao de integracao de pedido da mon  ³±±
±±³          ³ tadora                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³IA090I(CLIAS,NREG,NOPC)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PECAS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA090I(cAlias,nReg,nOpc)

If xFilial("VIG") != VIG->VIG_FILIAL .or. (VIG->(EOF()) .and. VIG->(BOF()))
	Help(" ",1,"ARQVAZIO")
	Return .f.
Endif

//Help(" ",1,"VFIMPMOD")

dbSelectArea("VIG")
//dbSeek( xFilial("VIG") + cCodMar )
dbSeek( xFilial("VIG") )

dbSelectArea("VOS")
dbSetOrder(1)
dbSeek(xFilial("VOS") + cCodMar )

dbSelectArea("VE4")
dbSetOrder(1)
dbSeek( xFilial("VE4") + cCodMar )

Processa( {|| FS_INTVIG()} )

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_INTVIG ³ Autor ³ Emilton               ³ Data ³ 20/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao dos dados do arquivo VIG p/ o arquivo VO6/VO7     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao montadora                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_INTVIG()

//Local cSegMod := ""
Local nRegTrans := 0
Local lTmpModelo := .f. , cQuebra := "", cContTime := ""


ProcRegua(VIG->(RecCount()))

//Begin Transaction

DbSelectArea("VIG")

While xFilial("VIG") == VIG->VIG_FILIAL .and. VIG->VIG_CODMAR == cCodMar .and. !VIG->(Eof())
	
	nRegTrans++
	
	If cQuebra # cCodMar+VIG->VIG_GRUSER+VIG->VIG_CODSER
		lTmpModelo := .f.
	EndIf
	
	dbSelectArea("VOS")
	dbSetOrder(1)
	dbSeek( xFilial("VOS")+cCodMar+Substr(VIG->VIG_CODSER,1,2))
	RecLock("VOS",!Found())
	VOS_FILIAL := xFilial("VOS")
	VOS_CODMAR := cCodMar
	VOS_CODGRU := Substr(VIG->VIG_CODSER,1,2)
	VOS_DESGRU := ALLTRIM(Substr(VIG->VIG_DESSER,1,20))
	MsUnLock()
	
	dbSelectArea("VO6")
	dbSetOrder(2)
	dbSeek( xFilial("VO6")+FG_MARSRV(cCodMar,VIG->VIG_CODSER)+VIG->VIG_CODSER )
	
	RecLock("VO6", !Found() )
	VO6_FILIAL := xFilial("VO6")
	If !found()
		VO6_SERINT := cSXENum
		cSXENum = STRZERO(VAL(cSXENum)+1,6)
	endif
	
	VO6_CODMAR := cCodMar
	VO6_GRUSER := left(VIG->VIG_CODSER,2)
	VO6_DESGRS := ALLTRIM(Substr(VIG->VIG_DESSER,1,20))
	VO6_CODSER := VIG->VIG_CODSER
	VO6_DESSER := VIG->VIG_DESSER
	VO6_DESABR := VIG->VIG_DESABR
	
	If !lTmpModelo .And. !Empty(VIG->VIG_TEMPAD)
		VO6_TEMFAB := VIG->VIG_TEMPAD*100
		VO6_TEMCON := VIG->VIG_TEMPAD*100
	EndIf
	
	VO6_QTDMEC := 1
	VO6_SERATI := "1"
	If VIG->VIG_TIPREG == "3"
		VO6_SERATI := "0"
	EndIf
	
	VO6_AGRSER := "N"
	VO6->VO6_AUTORI := VIG->VIG_AUTORI
	
	MsUnLock()
	
	DbSelectArea("VV2")
	DbSetOrder(1)
	If dbSeek( xFilial("VV2")+cCodMar+VIG->VIG_SEGMOD)
		
		lTmpModelo := .t.
		
		Do While !Eof() .And. xFilial("VV2") == VV2->VV2_FILIAL .and. VV2->VV2_CODMAR + RTrim(VV2->VV2_MODVEI) == cCodMar + RTrim(VIG->VIG_SEGMOD)
			
			dbSelectArea("VO7")
			dbSetOrder(1)
			dbSeek( xFilial("VO7")+FG_MARSRV(cCodMar,VIG->VIG_CODSER)+VIG->VIG_CODSER+VV2->VV2_MODVEI+VV2->VV2_SEGMOD )
			
			RecLock("VO7", !Found() )
			VO7_FILIAL := xFilial("VO7")
			VO7_CODMAR := cCodMar
			VO7_CODSER := VIG->VIG_CODSER
			VO7_MODVEI := VV2->VV2_MODVEI
			VO7_SEGMOD := VV2->VV2_SEGMOD
			VO7_TEMFAB := VIG->VIG_TEMPAD*100
			VO7_TEMCON := VIG->VIG_TEMPAD*100
			MsUnLock()
			
			dbSelectArea("VV2")
			dbSkip()
			
		EndDo
		
	EndIf
	
	
	If !RecLock("VIG",.F.,.T.)
		Help("  ",1,"REGNLOCK")
		DisarmTransaction()
		Break
	EndIf
	
	dbdelete()
	MsUnlock()
	//		WriteSx2("VIG")
	
	cQuebra := cCodMar+VIG->VIG_GRUSER+VIG->VIG_CODSER
	
	If cContTime # Substr(Time(),3,2)
		IncProc(OemtoAnsi(Transform(nRegTrans,"9999999")+"/"+Transform(VIG->(RecCount()),"9999999") ))    //"Importando dados!!"
		cContTime := Substr(Time(),3,2)
	EndIf
	
	dbSelectArea("VIG")
	dbSkip()
	
EndDo

//End Transaction

DbSelectArea("VIG")
DbCloseArea()
If ChkFile("VIG",.T.)
	Pack
	DbCloseArea()
EndIf
ChkFile("VIG",.F.)

If lMsErroAuto
	MostraErro()
EndIf

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IA090V    ³ Autor ³ Emilton               ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ visualiza os dados dos arquivos VID                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ AxVisual(cAlias,nReg,nOpc,aCampos)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA090V(cAlias,nReg,nOpc)

Private aCampos := {}

CPOIA090()
AxVisual(cAlias,nReg,nOpc,aCampos)

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CPOIA090  ³ Autor ³ Emilton               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pega os campos no SX3 para serem mostrados na visualizacao  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ CPOIA090()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPOIA090()

DbSelectArea("SX3")
dbgotop()
dbseek("VIG")
aCampos := {}

do While !eof() .and. x3_arquivo == "VIG"
	
	if X3USO(x3_usado) .And. cNivel>=x3_nivel
		aadd(aCampos,x3_campo)
	endif
	
	dbskip()
	
Enddo

DbSelectArea("VIG")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IA090GMºAutor  ³Fabio               º Data ³  03/27/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IA090GM()

Local cCabIte := "", lProcessou := .f., nRegTrans := 0, cNumVIM := "", cSeg2 := ""
Local cQuebra := ""
Local cFilVJ9 := xFilial("VJ9")
Local lTmpModelo := .f.
Local cCodSer := cGruSer := cSrvAdi := cTipReg := cAutOri := ""
Local cDesAbr := cDesSer := cContro := cAplica := cModEng := cDetEng := ""
Local nTemAnt := 0
Local nTemFab := 0
Local ni := 0
Local cTempo := time()
Local aVOS := {}
Local nOpca := 0
Private cMsgLog := "" , cMsgLogA := "" , cNome := ""
Private aMsgLog := {}

lAuto	:= .t.

cNome := Upper( cGetFile("(*.*) |*.*|" , OemToAnsi(STR0005),0, "SERVIDOR\EDI\IMPORTA\TMO\" ,.T., ,.T., .T.) )  //"Tabela de servicos"

If ( Empty(cNome) .Or. !File(cNome) )
	lMarcaTodos := .f.
	MsgStop(STR0007,STR0006) // Arquivo nao encontrado! ##"Atencao")
	Return
EndIf

If !( Upper(Substr(Right(Alltrim(cNome),12),1,2)) $ "TD/TZ/TT/TH" )
	lMarcaTodos := .f.
	MsgStop(STR0008 +" "+cNome+" "+STR0009,STR0006)   // nao podera ser importado para os segmentos TD/TZ/TT/TH!"  ## "Atencao")
	Return
EndIf

VIM->(DbSetOrder(3))
If ( VIM->(DbSeek( xFilial("VIM") + cCodMar + cNome )) .And. !MsgYesNo(STR0008 +" "+cNome+" "+STR0010,STR0006 ))//ja foi importado! Deseja importar novamente?" ###  "Atencao") )
	lMarcaTodos := .f.
	Return
EndIf

If ( Empty(cNome) .Or. !MsgYesNo(STR0011,STR0006) )  //Confirma importacao do arquivo? ## Atencao
	lMarcaTodos := .f.
	Return
EndIf

if (nHandle:= FT_FUse( cNome )) == -1
	lMarcaTodos := .f.
	Return
EndIf

If ( Upper(Substr(Right(Alltrim(cNome),12),1,2)) $ "TD/TZ" )
	cCabIte := "C"
ElseIf ( Upper(Substr(Right(Alltrim(cNome),12),1,2)) $ "TT/TH" )
	cCabIte := "I"
	cSeg2 := "TD"
	If Upper(Substr(Right(Alltrim(cNome),12),1,2)) $ "TH"
		cSeg2 := "TZ"
	EndIf
EndIf

&& Verifica se o arquivo CP ja foi importado
//If !FS_VLDIMP(Upper(Substr(Right(Alltrim(cNome),12),1,2)),"TMO",cSeg2,STR0012)    //"cadastro de servicos"
//	Return
//EndIf

If cCabIte == "C"
	ProcRegua(20)
	lProcessou := .t.
	dbSelectArea("VOS")
	DbSetOrder(1)
	DBGoTop()
	while !eof()
		aAdd(aVOS,{	VOS_FILIAL,VOS_CODMAR, VOS_CODGRU})
		DBSkip()
	enddo
	FT_FGotop()
	dbSelectArea("VO6")
	While !FT_FEof()
		cRecep := FT_FReadLN()
		//If ExistFunc("FS_TD1") .and. FS_TD1(.t.)
		//	cCodSer := left(SUBSTR(CRECEP,2,5)+space(15),15)
		//	cGruSer := left(cCodSer,2)
		//	cSrvAdi := left(SUBSTR(CRECEP,7,3)+space(3),3)
		//	cTipReg := If(SUBSTR(CRECEP,1,1)=="E","3",If(SUBSTR(CRECEP,1,1)=="A","2","1"))
		//	cAutOri := SUBSTR(CRECEP,10,1)
		//	cDesAbr := SUBSTR(CRECEP,11,35)
		//	cDesSer := SUBSTR(CRECEP,46,100)
		//	If cQuebra # cCodMar+cCodSer+cCodSer
		//		lTmpModelo := .f.
		//	EndIf
		//	nPos := aScan(aVOS, {|x| x[1]+x[2]+x[3] == xFilial("VOS")+cCodMar+cGruSer})
		//	dbSelectArea("VOS")
		//	If !dbSeek( xFilial("VOS")+cCodMar+cGruSer)
		//		RecLock("VOS",.t.)
		//		VOS_FILIAL := xFilial("VOS")
		//		VOS_CODMAR := cCodMar
		//		VOS_CODGRU := cGruSer
		//		VOS_DESGRU := ALLTRIM(Substr(cDesSer,1,20))
		//		MsUnLock()
		//		aAdd(aVOS,{xFilial("VOS"),cCodMar,cGruSer})
		//	EndIf
		//	dbSelectArea("VO6")
		//	dbSeek( xFilial("VO6")+FG_MARSRV(cCodMar,cCodSer)+cCodSer )
		//	RecLock("VO6", !Found() )
		//	VO6_FILIAL := xFilial("VO6")
		//	If !found()
		//		VO6_SERINT := cSXENum
		//		cSXENum = STRZERO(VAL(cSXENum)+1,6)
		//	endif
		//	VO6_CODMAR := cCodMar
		//	VO6_GRUSER := left(cCodSer,2)
		//	VO6_CODSER := cCodSer
		//	VO6_DESSER := cDesSer
		//	VO6_DESABR := cDesAbr
		//	VO6_QTDMEC := 1
		//	VO6_SERATI := If(cTipReg=="3","0","1")
		//	VO6_AGRSER := "N"
		//	If !lTmpModelo .And. !Empty(nTemFab)
		//		VO6_TEMFAB := nTemFab
		//	EndIf
		//	VO6->VO6_AUTORI := cAutOri
		//	MsUnLock()
		//	If VO6->VO6_SERATI == "0"
		//		dbSelectArea("VJ9")
		//		If dbSeek( xFilial("VJ9") + cCodMar + cCodSer )
		//			Do While !Eof() .And. VJ9->VJ9_FILIAL+VJ9->VJ9_CODMAR+VJ9->VJ9_CODSER == xFilial("VJ9") + cCodMar + cCodSer
		//				If VJ9->VJ9_SERATI # "0"
		//					RecLock("VJ9",.f.)
		//					VJ9->VJ9_SERATI := "0"
		//					MsUnLock()
		//				EndIf
		//				DbSkip()
		//			EndDo
		//		EndIf
		//	EndIf
		//EndIf
		cQuebra := cCodMar+cGruSer+cCodSer
		nRegTrans++
		If nRegTrans == 10000
			IncProc(STR0013)    //"Processando arquivo!"
			nRegTrans := 0
			If !Empty(cMsgLog)
				Aadd(aMsgLog,{cMsgLog})
				cMsgLog := ""
			EndIf
		EndIf
		FT_FSkip()
	End
	FT_FUse()
ElseIf cCabIte == "I"
	ProcRegua(60)
	lProcessou := .t.
	FT_FGotop()
	While !FT_FEof()
		cRecep := FT_FReadLN()
		//If ExistFunc("FS_TT1") .and. FS_TT1(.t., Upper(Substr(Right(Alltrim(cNome),12),1,2)) , cSeg2 )
		//	cCodSer := SUBSTR(CRECEP,2,5)
		//	cGruSer := left(cCodSer,2)
		//	cSrvAdi := left(SUBSTR(CRECEP,7,3)+space(3),3)
		//	cTipReg := If(SUBSTR(CRECEP,1,1)=="E","3",If(SUBSTR(CRECEP,1,1)=="A","2","1"))
		//	cContro := left(SUBSTR(CRECEP,10,5)+space(5),5)
		//	cAplica := left(SUBSTR(CRECEP,15,6)+space(6),6)
		//	cModEng := SUBSTR(CRECEP,21,6)
		//	cDetEng := SUBSTR(CRECEP,27,80)
		//	nTemAnt := (VAL(SUBSTR(CRECEP,111,4)) * 10 )
		//	nTemFab := (VAL(SUBSTR(CRECEP,107,4)) * 10 )
		//	If !Empty(cSrvAdi)
		//		dbSelectArea("VO6")
		//		dbSeek( xFilial("VO6")+cCodMar+left(cCodSer+space(15),15))
		//		cDesSer := VO6->VO6_DESSER
		//		cDesAbr := VO6->VO6_DESABR
		//		If !dbSeek( xFilial("VO6")+cCodMar+left(cCodSer+cSrvAdi+space(15),15))
		//			RecLock("VO6",.t.)
		//			VO6->VO6_FILIAL := xFilial("VO6")
		//			VO6->VO6_SERINT := cSXENum
		//			cSXENum = STRZERO(VAL(cSXENum)+1,6)
		//			VO6->VO6_CODMAR := cCodMar
		//			VO6->VO6_GRUSER := left(cCodSer,2)
		//			VO6->VO6_CODSER := left(cCodSer+cSrvAdi+space(15),15)
		//			VO6->VO6_DESSER := cDesSer
		//			VO6->VO6_DESABR := cDesAbr
		//		Else
		//			RecLock("VO6",.f.)
		//		EndIf
		//		VO6->VO6_QTDMEC := 1
		//		VO6->VO6_SERATI := If(cTipReg=="3","0","1")
		//		VO6->VO6_AGRSER := "N"
		//		If !Empty(nTemFab)
		//			VO6->VO6_TEMFAB := nTemFab
		//		EndIf
		//		MsUnLock()
		//	EndIf
		//	
		//	dbSelectArea("VJ9")
		//	if !dbSeek( cFilVJ9 + cCodMar + left(cCodSer+cSrvAdi+space(15),15) + cSrvAdi + cAplica + cContro )
		//		RecLock("VJ9",.t.)
		//		VJ9->VJ9_FILIAL := xFilial("VJ9")
		//		VJ9->VJ9_CODMAR := cCodMar
		//		VJ9->VJ9_CODSER := left(cCodSer+cSrvAdi+space(15),15)
		//		VJ9->VJ9_SRVADI := cSrvAdi
		//		VJ9->VJ9_APLICA := cAplica
		//		VJ9->VJ9_CONTRO := cContro
		//	Else
		//		RecLock("VJ9",.f.)
		//	Endif
		//	VJ9->VJ9_MODENG := cModEng
		//	VJ9->VJ9_DETENG := cDetEng
		//	VJ9->VJ9_TEMANT := nTemAnt
		//	VJ9->VJ9_TEMFAB := nTemFab
		//	If cTipReg == "3"
		//		VJ9->VJ9_SERATI := "0"
		//	Else
		//		VJ9->VJ9_SERATI := "1"
		//	EndIf
		//	MsUnLock()
		//	
		//EndIf
		nRegTrans++
		If nRegTrans == 10000
			IncProc(STR0013)    //"Processando arquivo!"
			nRegTrans := 0
			Aadd(aMsgLog,{cMsgLog})
			cMsgLog := ""
		EndIf
		FT_FSkip()
	End
	FT_FUse()
EndIf

If lProcessou
	
	&& Cria Registro por arquivo+segmento
	DbSelectArea("VIM")
	DbSetOrder(1)
	DbGoBottom()
	
	cNumVIM := Soma1(VIM->VIM_CODIGO,Len(VIM->VIM_CODIGO))
	
	DbSelectArea("VIM")
	DbSetOrder(3)
	DbSeek( xFilial("VIM") + cCodMar + cNome )
	
	RecLock("VIM", !Found() )
	VIM->VIM_FILIAL := xFilial("VIM")
	VIM->VIM_TIPPRO := "1"
	VIM->VIM_CODIGO := cNumVIM
	VIM->VIM_CODMAR := cCodMar
	VIM->VIM_ARQANT := Upper(cNome)
	VIM->VIM_SEGMEN := Upper(Substr(Right(Alltrim(cNome),12),1,2))+"1"
	VIM->VIM_DATPRO := dDataBase
	VIM->VIM_USRPRO := __cUserID
	VIM->VIM_STATUS := "3"
	MsUnLock()
	
	copy file(cNome) to "SERVIDOR\EDI\IMPORTA\TMO\"+Upper(Substr(Right(Alltrim(cNome),12),1,2))+"\"+Upper(Right(Alltrim(cNome),12))
	
	dele file(cNome)
	
Else
	
	MsgStop(STR0014,STR0006)//"Nao existe registros validos para importacao!" ## "Atencao")

EndIf

MsgAlert(STR0015+" "+cTempo+" a "+time(),STR0006)// Tempo Execucao: ## "Atencao")

If !Empty(cMsgLog) .or. len(aMsgLog) > 0
	cMsgLogA := cMsgLog
	For ni := 1 to len(aMsgLog)+1
		If ni <= len(aMsgLog)
			cMsgLog := aMsgLog[ni,1]
		Else
			cMsgLog := cMsgLogA
		EndIf
		DEFINE MSDIALOG oDlgLog TITLE OemtoAnsi(STR0016) FROM  08.1,10.6 TO 30.4,80.3 OF oMainWnd   //"Foram identificadas algumas inconsistencias no arquivo!"
		@ 001,001 GET oMsgLog VAR cMsgLog OF oDlgLog MEMO SIZE 273,140 PIXEL READONLY MEMO
		DEFINE SBUTTON FROM 152,190 TYPE 1 ACTION ( nOpca := 1, oDlgLog:End() ) ENABLE OF oDlgLog
		DEFINE SBUTTON FROM 152,240 TYPE 2 ACTION ( nOpca := 0, oDlgLog:End() ) ENABLE OF oDlgLog
		ACTIVATE MSDIALOG oDlgLog CENTER
		If nOpca == 0
			Exit                   
		EndIf
	Next
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef ºAutor  ³ Fabio               º Data ³  03/27/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criacao do menu.                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},; 	//Pesquisar
                     { STR0002 ,"IA090V", 0 , 2},;  //Visualizar
                     { STR0003 ,"IA090I", 0 , 3}} 	//Importar
Return aRotina
