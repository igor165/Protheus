// ษออออออออหออออออออป
// บ Versao บ 05     บ
// ศออออออออสออออออออผ

#INCLUDE "OFIIR010.ch"      //   COPIAR DO OFIIA200.CH
#Include "Fileio.ch"                                 
#Include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIIR010 ณ Autor ณ Rogerio Melonio TI1136ณ Data ณ 04/04/02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Interpretacao arquivos textos (transmissao/recepcao)       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Integracao                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIIR010 

Private aRotina := MenuDef()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho da tela de atualizacoes                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cCadastro := OemToAnsi(STR0003)               //"Impressao de Relatorios de EDI" //"Impressao de Relatorios de EDI"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DbSelectArea("VH6")
DbSetOrder(1)

If !Pergunte("INTVH6",.t.) 
   Return
Endif

Private cCodMar  := MV_PAR02
Private nQtd     := 0
Private cIte     := ""
Private cBase    := ""
Private cCaminh  := ""

dbSelectArea("VH1")
cIndVH1   := CriaTrab(nil,.f.)
cChavVH1  := "VH1_FILIAL+VH1_SEGMEN+VH1_CODMAR+VH1_CODGRU+VH1_ORDCAM"
IndRegua("VH1",cIndVH1,cChavVH1,,,STR0008) //"Aguarde, filtrando registros..."

dbSelectArea("VH6")
cIndVH6    := CriaTrab(nil,.f.)
cChavVH6  := IndexKey()
cCondVH6  := 'VH6_ORIGEM = "'+str(MV_PAR01,1)+'" .and. VH6_CODMAR ="'+cCodMar+'"'
IndRegua("VH6",cIndVH6,cChavVH6,,cCondVH6,STR0008) //"Aguarde, filtrando registros..."

mBrowse( 6, 1,22,75,"VH6")

dbSelectArea("VH1")
Set Filter to
RetIndex()
DbsetOrder(1)

dbSelectArea("VH6")
Set Filter to
RetIndex()
DbsetOrder(1)

#IFNDEF TOP
   If File(cIndVH1+OrdBagExt())
      fErase(cIndVH1+OrdBagExt())
   Endif
   If File(cIndVH6+OrdBagExt())
      fErase(cIndVH6+OrdBagExt())
   Endif
#ENDIF
   
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIIR0101 บAutor  ณ Rogerio Vaz Melonioบ Data ณ  04/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abertura do Arquivo texto de EDI                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIIR0101()
Local cArquivo:="" , cPathArq:=""
If Left(VH6->VH6_CODOPE,1) <> "R"
   MsgAlert(STR0012,STR0013) //Selecione segmento relacionado a Relatorio # Atencao 
   Return
Endif

Private _nHandle, _nLinhasTxt := 0, _nTamSeg := 0
Private _aCampos := {}, _aTitulos := {}, _cCabecalho := ""
Private cStr := "" , _aStruCampo := {}, _aSegmento := {}
Private _cSegmento := "", aConteudo := {}, nCol :=0 , _nColMax := 0

DbSelectArea("VE4")
DbSetOrder(1)
DbSeek(xFilial("VE4")+VH6->VH6_CODMAR)

DbSelectArea("VH2")                                    
DbSetOrder(1)
DbSeek(xFilial("VH2")+VH6->VH6_CODMAR+VH6->VH6_CODOPE) 
                      
cPathArq := "SERVIDOR"+If(Substr(&(alltrim(VH2->VH2_DIRECT)),1,1)#"\","\","") + &(alltrim(VH2->VH2_DIRECT))
cArquivo := cGetFile(OemToAnsi(STR0014)+"(*.*"+VE4->VE4_ESTACA+") |*.*"+VE4->VE4_ESTACA+"|" , OemToAnsi(STR0015),0, cPathArq ,.T., ,.T., .T. )
If Empty(cArquivo)
   Return
Endif
If (nHandle:= FT_FUse( cArquivo )) == -1
   MsgAlert(STR0016+" "+cArquivo+" "+STR0017,STR0013)//O arquivo de nome##nao pode ser aberto! Verifique os parametros. # atencao
   Return
Endif

MsgRun(STR0018,STR0019,{||OFIIR0106()})    //Aguarde... Preparando arquivo para leitura ## "Leitura de Arquivo"
Processa({|| OFIIR0102() },STR0020)   //"Processando..."

If Len(aConteudo) # 0
   If Empty(VH2->VH2_CAMMAC)
      MsgRun(STR0021,STR0022,{||OFIIR0103()}) //"Aguarde... Montando estrutura do relatorio" ##"Estrutura do relatorio"
      MsgRun(STR0023,STR0024,{||OFIIR0107()}) //"Aguarde... Ordenando registros lidos"  # "Organizando registros"
      OFIIR0104()
   Else
      &(Trim(VH2->VH2_CAMMAC))
   Endif   
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OFIIR0102บ Autor ณ Rogerio Vaz Melonioบ Data ณ  08/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Leitura de arquivo de EDI                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Modulo de Oficina                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function OFIIR0102()

DbSelectArea("VH0")  
DbSetOrder(1)
DbSelectArea("VH3")  
DbSetOrder(1)
DbSeek( xFilial("VH3")+VH6->VH6_CODMAR+VH6->VH6_CODOPE )
_nTamSeg    := Val(Left(VH6->VH6_FILTRO,3))
//_cPosBloc1  := Substr(VH6->VH6_FILTRO,005,007)
//_cPosBloc2  := Substr(VH6->VH6_FILTRO,013,007)
//_cBloco1    := "Substr(cStr,"+_cPosBloc1+")"
//_cBloco2    := "Substr(cStr,"+_cPosBloc2+")"

_aSegmento  := {}
While !Eof() .And. VH3->VH3_FILIAL+VH3->VH3_CODMAR+VH3->VH3_CODPAR == xFilial("VH3")+VH6->VH6_CODMAR+VH6->VH6_CODOPE
   DbSelectArea("VH0")  
   DbSeek( xFilial("VH0")+VH3->VH3_CODMAR+VH3->VH3_CODGRU )
   Aadd(_aSegmento,Left(VH0->VH0_SEGMEN,_nTamSeg))
   dbSelectArea("VH3")
   dbSkip()
Enddo   
   
FT_FGotop()
ProcRegua(_nLinhasTxt)

_cLinhaTxt := 0
While ! FT_FEof()
   _cLinhaTxt++
   IncProc(STR0025+" "+StrZero(_cLinhaTxt,6)+"/"+StrZero(_nLinhasTxt,6))  //Processando linha
   cStr := FT_FReadLN()
   _cSegmento := Left(cStr,_nTamSeg)
   _nPosSeg := Ascan(_aSegmento,_cSegmento)
   _lPulaLinha := Substr(cStr,1,1)+Substr(cStr,3,1) $ "CI/CF/FI/FF" ;
                  .Or. _nPosSeg == 0
   If !_lPulaLinha
      Aadd(aConteudo,{_cSegmento,cStr})
   EndIf	
   FT_FSkip()
EndDo
FT_FUse()

Return                       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OFIIR0103บ Autor ณ Rogerio Vaz Melonioบ Data ณ  08/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Emissao de Relatorio EDI                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Modulo de Oficina                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function OFIIR0103()
Local nOcorrencia := 0
nCol        := 0
_nColMax    := 0
_nIni       := 1
_nTamSeg   := Val(Left(VH6->VH6_FILTRO,1))
DbSelectArea("VH3")  
DbSetOrder(1)
DbSeek( xFilial("VH3")+VH6->VH6_CODMAR+VH6->VH6_CODOPE )
While !Eof() .And. VH3->VH3_FILIAL+VH3->VH3_CODMAR+VH3->VH3_CODPAR == xFilial("VH3")+VH6->VH6_CODMAR+VH6->VH6_CODOPE
   nCol        := 0
   _nIni       := 1
   DbSelectArea("VH0")  
   DbSeek( xFilial("VH0")+VH3->VH3_CODMAR+VH3->VH3_CODGRU )
   _cSegmento := Left(VH0->VH0_SEGMEN,_nTamSeg)
   For nOcorrencia:=1 To VH0->VH0_BLCLIN
       nPreBlc := 0
       DbSelectArea("VH1")  
       DbSeek( xFilial("VH1")+VH0->VH0_SEGMEN+VH3->VH3_CODMAR+VH3->VH3_CODGRU )
       Do While !Eof() .And. Left(VH0->VH0_SEGMEN,_nTamSeg) == _cSegmento .and. VH1->VH1_CODGRU == VH3->VH3_CODGRU .And. VH1->VH1_FILIAL == xFilial("VH1")
    	    nPreBlc++
   	      If (( Empty(VH0->VH0_BLCLIN) .Or. nPreBlc > VH0->VH0_PREBLC ) ;
			          .And. ( Empty(VH0->VH0_BLCLIN) .Or. nPreBlc <= VH0->VH0_PREBLC+VH0->VH0_ITEBLC )) ;
			          .Or.  ( nOcorrencia == 1 .And. ( nPreBlc <= VH0->VH0_PREBLC ) ) ;
   			        .Or.  ( nOcorrencia == VH0->VH0_BLCLIN .And. ( nPreBlc > VH0->VH0_PREBLC+VH0->VH0_ITEBLC ) )
             _aStruCampo := {_nIni,Val(VH1->VH1_TAMCAM),nCol,VH1->VH1_FUNIMP,VH1->VH1_FUNEXP,VH1->VH1_PICCAM,nOcorrencia}
             Aadd(_aCampos , _aStruCampo )
			       _nIni += Val(VH1->VH1_TAMCAM)
             _nTamPict  := Max(Len(Trim(Substr(VH1->VH1_PICCAM,4))),Val(VH1->VH1_TAMCAM)) 
             _nTamCampo := Max(Len(Trim(VH1->VH1_DESCAM)),_nTamPict)
	           If Left(VH1->VH1_FUNEXP,1) == "S"
                nCol += (_nTamCampo + 3)
  		          If nOcorrencia == 1
				           _cCabecalho := Left(_cCabecalho+VH1->VH1_DESCAM+Space(nCol),nCol-1)
				        Endif   
             Endif   
          EndIf   
          dbskip()                                        
       EndDo
       If nCol > _nColMax
          _nColMax := nCol
       Endif
       nCol := 0
   Next
   dbSelectArea("VH3")
   dbSkip()
Enddo   

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OFIIR0104บ Autor ณ Rogerio Vaz Melonioบ Data ณ  05/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Emissao de Relatorio EDI                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Modulo de Oficina                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function OFIIR0104()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cInd
Local cDesc1       := STR0026	//"Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := STR0027	//"de acordo com os parametros informados pelo usuario."
Local cDesc3       := STR0028	//"Impressao de Arquivo de EDI"
Local cPict        := ""
Local titulo       := Trim(VH0->VH0_NOMGRU)
Local nLin         := 80
Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := If(_nColMax<80,80,If(_nColMax<131,132,220))
Private tamanho          := If(_nColMax<80,"P",If(_nColMax<131,"M","G"))
Private nomeprog         := "OFIIR0104" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 15
Private aReturn          := { STR0030, 1, STR0031, 1, 2, 1, "", 1} //Zebrado # Administracao
Private nLastKey        := 0
Private cPerg       := nil
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "OFIIR0104" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    := "VH6"

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| OFIIR0105(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ OFIIR0105บ Autor ณ AP6 IDE            บ Data ณ  05/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de impressao do Relatorio de EDI.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function OFIIR0105(Cabec1,Cabec2,Titulo,nLin)
Local _nPosCpo := 0
SetRegua(Len(aConteudo))
_cSegmento := aConteudo[1,1]
Cabec1   := _cCabecalho
_nLinha := 1

While _nLinha <= Len(aConteudo)

   If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif

   If lAbortPrint
      @nLin,00 PSAY STR0029   //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   While aConteudo[_nLinha,1] == _cSegmento 
      _nColAnt := 0
      For _nPosCpo := 1 To Len(_aCampos)
         _cImprime := Left(_aCampos[_nPosCpo,5],1)
         If _cImprime == "S"
            _nPosIni   := _aCampos[_nPosCpo,1]
            _nTamCpo   := _aCampos[_nPosCpo,2]
            _nColImp   := _aCampos[_nPosCpo,3]
            _cTipoDado := _aCampos[_nPosCpo,4]
            _cPicture  := _aCampos[_nPosCpo,6]
            _cDadoImp  := SubStr(aConteudo[_nLinha,2],_nPosIni,_nTamCpo)

            If Left(_cTipoDado,6) == "_VALOR"
               _nCasasDec := Val(Substr(_cTipoDado,8,1))
               _nDiv100   := Val("1"+Replicate("0",_nCasasDec))
               _cDadoImp  := Val(_cDadoImp)/_nDiv100
            Endif

            If _nColImp < _nColAnt
               nLin++
            Endif    
            @ nLin,_nColImp PSAY Transform(_cDadoImp,_cPicture)
            _nColAnt := _nColImp
            
         Endif

      Next   

      IncRegua()
      nLin++
      If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
         Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
         nLin := 9
      Endif

      _nLinha++
      If _nLinha > Len(aConteudo)
         Exit
      Endif   

   Enddo

   If _nLinha > Len(aConteudo)
      Exit
   Endif   

Enddo

nLin++

@ nLin,000 PSAY Repl("-",limite)

SET DEVICE TO SCREEN

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ OFIIR0106บ Autor ณ AP6 IDE            บ Data ณ  12/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina para retornar qtd. de linhas do arquivo de EDI.     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function OFIIR0106()
FT_FGotop()
While ! FT_FEof()             
   _nLinhasTxt ++
   FT_FSkip()
EndDo
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ OFIIR0107บ Autor ณ AP6 IDE            บ Data ณ  12/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina para ordenar registros lidos  do arquivo de EDI.    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function OFIIR0107()
Asort(aConteudo,,,{|x,y| x[1]<y[1]})
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ MenuDef  บ Autor ณ AP6 IDE            บ Data ณ  12/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Criacao do menu.											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1 },; //"Pesquisar"
                 {  STR0002 ,"OFIIR0101()" , 0 , 2 } }  //Imprimir //"Imprimir"
Return aRotina
