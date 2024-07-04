#Include "MATA462C.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ FUNCAO   ³ MATA462C ³ AUTOR ³ Bruno Sobieski        ³ DATA ³ 06.08.02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DESCRICAO³ Conformaci¢n de remitos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ Generico - Localizacoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mata462C() 
Local aCampos := {},lPerg	:=	.F.
Local cCondicao := ""
Local bFilBrw := {|| .T.}
Local nX:=0
Private aRotina,aIndices	:=	{}
Private cCadastro
Private cMarca := GetMark(,'SD2','D2_OK')
Private aListRlock	:=	{}
dbSelectArea("SD2")
aRotina := { { OemToAnsi(STR0001),'LocxPesq(bFilBrow)' , 0 , 1},;  //"bUscar"
             { OemToAnsi(STR0002), 'A462Conf', 0 , 3} }  //"Conformar"

cCadastro := OemToAnsi(STR0003) + GetDESCREM()

//+--------------------------------------------------------------+
//¦ Verifica as perguntas           									  ¦
//+--------------------------------------------------------------+
//+--------------------------------------------------------------+
//¦ Variaveis utilizadas para parametros								  ¦
//¦ mv_par01     // Filtra já conformados  - Sim/Nao             ¦
//¦ mv_par02     // Trazer Rem. Marcados   - Sim/Nao             ¦
//¦ mv_par03     // Cliente                                      ¦
//¦ mv_par04     // Sucursal                                     ¦
//¦ mv_par05     // De fch.emission                              ¦
//¦ mv_par06     // Hasta fch.                                   ¦
//+--------------------------------------------------------------+
While Pergunte("MT462C",.T.)
   dbSelectArea("SA1")
   dbSetOrder(1)
   If MsSeek( xFilial("SA1")+mv_par03+mv_par04)
      If A1_CONFREM=="1" // 1-Sim/2-Nao
         lPerg := .T.
         Exit
      Else
         Help(" ",1,"NOCONF")
      EndIf
   Else
      Help(" ",1,"NOCLIENTE")
   EndIF
End
If !lPerg
   dbSelectArea("SD2")
   dbSetOrder(1)
   Return
EndIf


aCampos:= {	{"D2_OK"     ,"","  "}}
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( "SD2" )
While !Eof() .And. ( X3_ARQUIVO == "SD2" )
	If cNivel >= X3_NIVEL .And. X3_BROWSE=="S"
		AADD(aCampos,{  X3_CAMPO,"", TRIM(X3Titulo()), X3_PICTURE } )
	EndIf
	dbSkip()
Enddo



cCondicao := 'D2_FILIAL=="'+xFilial("SD2")+'".And.D2_CLIENTE=="'+mv_par03+'".And.D2_LOJA=="'+mv_par04+'"'
cCondicao := cCondicao + '.And.DtoS(D2_EMISSAO)>="'+DtoS(mv_par05)+'".And.DtoS(D2_EMISSAO)<="'+DtoS(mv_par06)+'"'
cCondicao := cCondicao + '.And.D2_TIPOREM=="0".And.D2_QTDEFAT==0 .And.(D2_QUANT-D2_QTDEDEV)>0 '
If mv_par01 == 1
   cCondicao := cCondicao + '.And.D2_QTDAFAT==0 '
Else
   cCondicao := cCondicao + '.And.(D2_QTDAFAT==0 .Or. D2_QTDAFAT==(D2_QUANT-D2_QTDEDEV))'
EndIf

bFilBrw	:=	{|| FilBrowse("SD2",@aIndices,cCondicao)}
Eval( bFilBrw )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Marca os registros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par02 == 1
	Processa({| | a462CMrkAll()})
Endif

dbGoTop()

MarkBrow("SD2","D2_OK","!D2_QTDAFAT",aCampos,   ,cMarca ,"Processa({| | a462CMrkAll()})",,,,"a462CMrk()")        

EndFilBrw("SD2",@aIndices)

For nX := 1 To Len(aListRlock)
	SD2->(DbGoTo(aListRlock[nX]))
	SD2->(MsRUnLock(aListRlock[nX]))
Next nX
	
dbSelectArea("SD2")
dbSetOrder(1)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ FUNCAO   ³ A462Conf ³ AUTOR ³ Bruno Sobieski        ³ DATA ³ 06.08.02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DESCRICAO³ Conformaci¢n de remitos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ MATA462C- Localizacoes                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A462Conf()


//+-------------------------------------------------------------+
//¦ Confirmacao da Geracao do Remito.                           ¦
//+-------------------------------------------------------------+

If !MsgYesNo(OemToAnsi(STR0004), OemToAnsi(STR0005))  //"¨Confirma la conformaci¢n de los Remitos marcados?","Atenci¢n"
   Return
EndIf

DbGoTop()

While !Eof()
   If !Ismark("D2_OK")
      DbSkip()
      Loop
   Endif

   //+------------------------------------------------------+
   //¦ Conformaci¢n                                         ¦
   //+------------------------------------------------------+
   dbSelectArea("SD2")
   RecLock("SD2",.F.)
   Replace  D2_QTDAFAT   With  (D2_QUANT-D2_QTDEDEV)
	Replace  D2_GERANF	 With  "S"	
   MsUnLock()
   DbCommitAll()

   DbSkip()

EndDo

dbSelectArea("SD2")
dbGoTop()

aRotina[2][4] := 0
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a462CMrkAll  ºAutor  ³Bruno Sobieski   ºFecha ³  06.08.02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de marca Tudo definida aqui para usar a a462CMrk     º±±
±±º          ³ e tratar os locks do SD2                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A462CMrkAll()
Local nRecno	:=	0

DbSelectArea("SD2")
ProcRegua(Reccount())
nRecno	:=	Recno()
DbGoTop()

While !EOF()
	IncProc()
	A462CMrk(.T.)
	DbSelectArea("SD2")
	DbSkip()
Enddo
DbGoTo(nRecno)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a462CMrk  ºAutor  ³Bruno Sobieski      ºFecha ³  06.08.02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de marca da MarkBrowse, definida aqui para tratar os º±±
±±º          ³ locks do SD2     a efeitos ad concorrencia de processos.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a462CMrk(lAll)

Local lRet	:=	.F.
Local nX	:=	0
Local nPosLock := 0
Local cMsg		:=	OemToAnsi(STR0006)//"El documento en uso y no puede ser marcado en este momento"
Local lShwHlp	:=	.F.      

lAll	:=	Iif(lAll == Nil,.F.,lAll)

lShwHlp	:=	!lAll
DbSelectArea("SD2")
If D2_OK == cMarca
	RecLock("SD2",.F.)
	Replace D2_OK 	 		With "  "
	MsRUnLock(Recno())
	nPosLock	:=	Ascan(aListRlock,SD2->(Recno()))
	Adel(aListRlock,nPosLock)
	aSize(aListRlock,Len(aListRlock)-1)
	lRet:= .T.
Else	
	If D2_QTDAFAT==0 
		For nX	:=	0	To 1 STEP 0.2
			If  MsRLock()
				AAdd(aListRlock,SD2->(Recno()))
				Replace D2_OK 		With cMarca
				nX := 1
				lRet:=	.T.
			Else
				Inkey(0.2)
			Endif
		Next
	Else
		lShwHlp	:=	.F.
	Endif
EndIf


If !lRet.And.lShwHlp
	MsgAlert(cMsg)
Endif

Return lRet
