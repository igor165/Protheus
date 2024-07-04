#INCLUDE "HSPAHP04.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ HSPAHP04 ณ Autor ณ ณ data ณ 						 18/10/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Movimentacao de Leitos na Reserva de leitos                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHP04()

Local aSize:={},aObjs:={},aInfo:={},aPObj:={},aPEnc:={}, aPAux := {},aPMem := {},aPGet := {}
Local aButtons := {}
Local aCBrwPac:=FS_ExibGav() /// Exibicao de Campos Selecionados na GMT

Private bKeyF5 		:= SetKey(VK_F5, {|| FS_REFRESH()})

Private aCorM39 := {{"GMJ_STATUS == '0'", "BR_VERDE"   }, ; //Horario Livre
{"GMJ_STATUS == '1'", "BR_VERMELHO"}, ; //Horario Ocupado
{"GMJ_STATUS == '2'", "BR_AMARELO" }, ; //Horario Bloqueado
{"GMJ_STATUS == '3'", "BR_AZUL"    }}   //Horario Atendido

Private aCorM35 := {{"GAV_TIPO == '3'",'BR_VERDE'   }, ;
{"GAV_TIPO == '2' .Or. GAV_TIPO == '5' .Or. GAV_TIPO == '6'",'BR_AMARELO' }, ;
{"GAV_TIPO == '1'",'BR_AZUL'    }, ;
{"GAV_TIPO == '4'",'BR_VERMELHO'}, ;
{"GAV_TIPO == '7'",'BR_BRANCO'  }, ;
{"GAV_TIPO == '0'",'BR_CINZA'   }}

Private 	aCor := {{"GAV_STATUS == '0' .Or. GAV_STATUS == ' ' " , "BR_VERDE"   },;
{"GAV_STATUS == '2'"                              , "BR_AMARELO"},;
{"GAV_STATUS == '1'"                              , "BR_MARROM"  },;
{"GAV_STATUS == '3'"                              , "BR_BRANCO"  },;
{"GAV_STATUS == '4'"                              , "BR_PRETO"   },;
{"GAV_STATUS == '5'"                              , "BR_CINZA"  }}

Private	aCorPrio := {{"GT6_TPRESE == '0'  " 	  , "BR_VERMELHO"},;
{"GT6_TPRESE == '1'"                              , "BR_MARROM" },;
{"GT6_TPRESE == '2'"                              , "BR_PRETO"  },;
{"GT6_TPRESE == '3'"                              , "BR_CINZA"  },;
{"GT6_TPRESE == '4'"                              , "BR_AMARELO"},;
{"GT6_TPRESE == '5'"                              , "BR_BRANCO"  }}


Private aCorLeito := {{"GAV->GAV_STATUS == '0' .Or. GAV->GAV_STATUS == ' '", "BR_VERDE"   , HS_RDescrB("GAV_STATUS", "0")},;
{"GAV->GAV_STATUS == '2'"                            , "BR_VERMELHO", HS_RDescrB("GAV_STATUS", "1")},;
{"GAV->GAV_STATUS == '1'"                            , "BR_MARROM"  , HS_RDescrB("GAV_STATUS", "2")},;
{"GAV->GAV_STATUS == '3'"                            , "BR_BRANCO"  , HS_RDescrB("GAV_STATUS", "3")},;
{"GAV->GAV_STATUS == '4'"                            , "BR_PRETO"   , HS_RDescrB("GAV_STATUS", "4")},;
{"GAV->GAV_STATUS == '5'"                            , "BR_CINZA"   , HS_RDescrB("GAV_STATUS", "5")}}

Private nGDOpc		:= GD_UPDATE + GD_DELETE + GD_INSERT
Private nOpcAut		:= 0
Private nReg 		:= 0
Private nUGMJ		:= 0
Private nUGAV		:= 0
Private nUGAVP		:= 0
Private nUGAVC		:= 0
Private nUGT6		:= 0
Private nUGT5		:= 0

Private Inclui 		:= .F.
Private lAtuDado	:= .F.

Private oGetGav  	:= nil
Private oGetGMJ  	:= nil
Private oGetGavC  	:= nil
Private oGetGavP  	:= nil
Private oGetGT6  	:= nil

Private aHeadGT5 	:= {}, aColsGT5 := {}
Private aHeadGMJ 	:= {}, aColsGMJ := {}
Private aHeadGT6 	:= {}, aColsGT6 := {}
Private aHeadGAVC 	:= {}, aColsGAVC := {}
Private aHeadGAVP 	:= {}, aColsGAVP := {}

Private cCadastro  	:= OemToAnsi(STR0001) //"Reserva de Leitos" //"Reserva de Leitos"
Private cGcyAtendi  :="0"
Private aPPac		:= {}

Private nGMJRegGer 	:=0
Private nGMJRegAte 	:=0
Private nGMJDatInt 	:=0
Private nGMJCrm 	:=0
Private nGMJNome	:=0
Private nGMJCodLoc  :=0
Private nGMJCodQua  :=0
Private nGMJIdade    :=0
Private nGMJTPLoc    :=0
Private nGMJPlano    :=0

Private nGavRegGer 	:=0
Private nGavRegate  :=0
Private nGavNome	:=0
Private nGAVCodLoc  :=0
Private nGAVCodQua  :=0
Private nGAVCodLei  :=0
Private nGAVDatInt  :=0
Private nGAVCrm		:=0
Private nGAVIdade    :=0
Private nGAVTPLoc    :=0 
Private nGAVReserv    :=0 

Private nGVCRegGer	:=0
Private nGVCRegate  :=0
Private nGVCNome	:=0
Private nGVCCodLoc  :=0
Private nGVCCodQua  :=0
Private nGVCCodLei  :=0
Private nGVCDatInt  :=0
Private nGVCCrm		:=0
Private nGVCIdade   :=0
Private nGVCTPLoc   :=0
Private nGVCReserv  :=0 

Private nGT6RegGer := 0
Private nGT6Nome   := 0
Private nGT6CodLoc := 0
Private nGT6CodQua   := 0
Private nGT6CodLei := 0
Private nGT6TPrese   := 0
Private nGT6Idade := 0
Private nGT6TipLoc   := 0
Private nGT6TipCon   := 0

Private nGT5CODLOC	:=0
Private nGT5QUARTO	:=0
Private nGT5LEITO	:=0
Private nGT5TPRESE	:=0
Private nGT5PSETOR	:=0
Private nGT5PIDADE	:=0
Private nGT5PREINT	:=0
Private nGT5PDATA 	:=0
Private nGT5PLEIES	:=0
Private nGT5PTIPO 	:=0
Private nGT5CID   	:=0
Private nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
Private cOrdGT6 :='GT6_CODLOC,GT6_TPRESE'
Private aJoinGT6 := {{     " JOIN " + RetSqlName("GT5") + " GT5 ", " " , "GT5.GT5_FILIAL = '" + xFilial("GT5") + "' AND GT5.D_E_L_E_T_ <> '*' AND GT5.GT5_CODLOC = GT6.GT6_CODLOC AND GT5.GT5_QUARTO = GT6.GT6_QUARTO AND GT5.GT5_LEITO = GT6.GT6_LEITO  ", " "}}


aSize := MsAdvSize(.T.)
aObjs := {{100, 050, .T., .T.,.T.}, ;
{100, 050, .T., .T., .T.} }

aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObj := MsObjSize(aInfo, aObjs, .T.)
aObjs := {{100, 50, .T., .T.}, ;
{100, 50, .T., .T.}}

aInfo := {aPObj[1, 2], aPObj[1, 1], aPObj[1, 4], aPObj[1, 3], 0, 0}
aPEnc := MsObjSize(aInfo, aObjs, .T.)

aObjs := {{100, 50, .T., .T.}, ;
{100, 25, .T., .T.},;
{100, 25, .T., .T.}}

aInfo := {aPEnc[2, 2], aPEnc[2, 1], aPEnc[2, 4], aPEnc[2, 3], 0, 0}
aPAux := MsObjSize(aInfo, aObjs, .T.,.T.,.T.)

aObjs := {{100, 100, .T., .T.}}

aInfo := {aPEnc[1, 2], aPEnc[1, 1], aPEnc[1, 4], aPEnc[1, 3], 0, 0}
aPPac := MsObjSize(aInfo, aObjs, .T.,.T.)


DEFINE MSDIALOG oDlgAut TITLE OemToAnsi(cCadastro ) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL

oPanel1  := tPanel():New(aPObj[2, 1], aPObj[2, 2],, oDlgAut,,,,,, aPObj[2, 3], aPObj[2, 4])
oPanel1:Align := CONTROL_ALIGN_BOTTOM

oPanel2 := tPanel():New(aPPac[1, 1], aPPac[1, 2],, oDlgAut,,,,,, aPPac[1, 3], aPPac[1, 4])
oPanel2:Align := CONTROL_ALIGN_LEFT

oPanel3 := tPanel():New(aPEnc[1, 1], aPEnc[1, 2],, oDlgAut,,,,,, aPEnc[1, 3], aPEnc[1, 4])
oPanel3:Align := CONTROL_ALIGN_ALLCLIENT

@ aPObj[2, 1], aPObj[2, 2] FOLDER oFolder SIZE aPObj[2, 3], aPObj[2, 4]  OF oPanel1 PIXEL PROMPTS STR0002,STR0003,STR0004 //"Agenda Cirurgica"###"Centro Cirurgico"###"Posto de Enfermagem"
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

//Mapa de Leitos
oGetGav:=HS_MBrow(oPaneL2, "GAV"    , {aPPac[1, 1], aPPac[1, 2], aPPac[1, 3],/*aPPac[1, 4]*/ Iif(OAPP:LMDI,aPPac[1, 4]-20,aPPac[1, 4]-30)}   ,        ,        ,        , aCorLeito,          ,         ,         ,           ,        , 	     ,       , 	 .F.      , aCBrwPac   ,       ,       , aCBrwPac                , .T.)

//Parametriza็ใo de Leitos somente para ordena็ใo dos Dados da GT6
HS_BDados("GT5" , @aHeadGT5 , @aColsGT5 , @nUGT5  , 1   ,         ,"GT5.GT5_FILIAL = '" + xFilial("GT5") + "' AND  GT5.D_E_L_E_T_<>'*' "								 																																																												  ,         ,                      ,         ,         ,        ,        ,       																																			,        																																			, .T.    ,         ,        ,         ,           ,  		 , /*aCposVis*/ ,           ,          , 		,/*aCposVis*/)
nGT5CODLOC	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_CODLOC"})
nGT5QUARTO	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_QUARTO"})
nGT5LEITO	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_LEITO "})
nGT5TPRESE 	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_TPRESE"})
nGT5PSETOR	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PSETOR"})
nGT5PIDADE	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PIDADE"})
nGT5PREINT	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PREINT"})
nGT5PDATA 	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PDATA "})
nGT5PLEIES	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PLEIES"})
nGT5PTIPO 	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PTIPO "})
nGT5CID   	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_CID   "})
//Lista de Espera
HS_BDados("GT6" , @aHeadGT6, @aColsGT6  , @nUGT6  , 1   ,              ,"GT6.GT6_FILIAL = '" + xFilial("GT6") + "' AND  GT6.D_E_L_E_T_<>'*' "																												 ,        , "GT6_TPRESE"         ,         ,         , /*cCamposNao*/,        ,        ,        ,  /*.T.*/   , aCorPrio,        ,   /*.T.*/   ,           ,         ,         ,aJoinGT6  ,          , cOrdGT6,                                                       )
nGT6RegGer := aScan(aHeadGT6, {|aVet| aVet[2] == "GT6_REGGER"})
nGT6Nome   := aScan(aHeadGT6, {|aVet| aVet[2] == "GT6_NOME  "})
nGT6CodLoc	:= aScan(aHeadGT6, {|aVet| aVet[2] == "GT6_CODLOC"})
nGT6CodQua	:= aScan(aHeadGT6, {|aVet| aVet[2] == "GT6_QUARTO"})
nGT6CodLei	:= aScan(aHeadGT6, {|aVet| aVet[2] == "GT6_LEITO "})
nGT6TPrese	:= aScan(aHeadGT6, {|aVet| aVet[2] == "GT6_TPRESE"})
nGT6Idade	:= aScan(aHeadGT6, {|aVet| aVet[2] == "GT6_IDADE "})
nGT6TipLoc	:= aScan(aHeadGT6, {|aVet| aVet[2] == "GT6_TIPLOC"})
nGT6TipCon  := aScan(aHeadGT6, {|aVet| aVet[2] == "GT6_TIPCON"})


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe possuir Registro na Lista de Espera ณ
//ณRealiza a ordena็ใo deste conforme     ณ
//ณParametriza็ใo de Cada Setor           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


If !Empty(aColsGT6[1,nGT6CodLoc])
	Fs_ordem(aColsGT6,aColsGT5)
Endif

oGetGT6 := MsNewGetDados():New(aPEnc[2, 1]+115 , aPEnc[2, 2] , aPEnc[2, 3]  , aPEnc[2, 4] , 0      ,,,             ,,,      ,,,, oPaneL3, aHeadGT6, aColsGT6)
oGetGT6:oBrowse:Align 	:= CONTROL_ALIGN_BOTTOM
oGetGT6:oBrowse:BlDblClick := {|| iif(aScan(aHeadGT6, {|aVet| aVet[2] == "GT6_REGGER"})>0,HS_HP14Tra(oGetGT6,0),.F.)}


//Agenda Cirurgica
HS_BDados("GMJ", @aHeadGMJ , @aColsGMJ , @nUGMJ , 1   ,        , "GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.GMJ_DATAGE >= '" + DToS(dDataBase) + "' AND (GMJ.GMJ_STATUS = '1' OR GMJ.GMJ_STATUS = '3') AND GMJ.GMJ_CODAGE = GMJ.GMJ_SEQAGE  AND GMJ.GMJ_REGGER   NOT IN ( SELECT GT6_REGGER   FROM " + RetSqlName("GT6") + " GT6 WHERE GT6.GT6_FILIAL = '" + xFilial("GT6") + "' AND GT6.D_E_L_E_T_ <> '*' )",         ,"GMJ_STATUS",         ,        ,        ,         ,        ,        ,   .t.     ,aCorM39  ,        ,         ,           ,         ,         ,            ,          ,        ,          ,)
nGMJRegGer	:= aScan(aHeadGMJ, {|aVet| aVet[2] == "GMJ_REGGER"})
nGMJNome	:= aScan(aHeadGMJ,   {|aVet| aVet[2] == "GMJ_NOMPAC"})
nGMJCodLoc 	:= aScan(aHeadGMJ,   {|aVet| aVet[2] == "GMJ_CODLOC"})
nGMJCodQua 	:= aScan(aHeadGMJ,   {|aVet| aVet[2] == "GMJ_QUARTO"})
nGMJCodAge 	:= aScan(aHeadGMJ,   {|aVet| aVet[2] == "GMJ_CODAGE"})
nGMJRegAte 	:= aScan(aHeadGMJ,   {|aVet| aVet[2] == "GMJ_REGATE"})
nGMJDatInt 	:= aScan(aHeadGMJ,   {|aVet| aVet[2] == "GMJ_DATINT"})
nGMJCrm		:= aScan(aHeadGMJ,   {|aVet| aVet[2] == "GMJ_CODCRM"})
nGMJIdade	:= aScan(aHeadGMJ,   {|aVet| aVet[2] == "GMJ_IDADE "})
nGMJPlano	:= aScan(aHeadGMJ,   {|aVet| aVet[2] == "GMJ_CODPLA"})

oGetGMJ := MsNewGetDados():New(aPObj[2, 1] , aPObj[2, 2] , aPObj[2, 3] , aPObj[2, 4] , 0      ,,,             ,,,      ,,,, oFolder:aDialogs[1], aHeadGMJ, aColsGMJ)
oGetGMJ:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
oGetGMJ:oBrowse:BlDblClick := {|| iif(aScan(aHeadGMJ, {|aVet| aVet[2] == "GMJ_REGGER"})>0,HS_HP14Tra(oGetGMJ,oFolder:nOption),.F.)}


//Centro Cirurgico
HS_BDados("GAV", @aHeadGAVC, @aColsGAVC,@nUGAVC,  1   ,        , "GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.GAV_STATUS = '1' AND GAV.GAV_REGGER NOT IN( SELECT GT6_REGGER  FROM " + RetSqlName("GT6") + " GT6 WHERE GT6.GT6_FILIAL = '" + xFilial("GT6") + "' AND GT6.D_E_L_E_T_ <> '*'  ) OR GAV_RESERV  IN ( '0', '1', '2', '3', '4', '5')   ",        ,"GAV_STATUS",         ,        ,        ,        ,/*cCpoMark*/,/*cMarDef*/,    .t.    ,aCorM35,        ,         ,          ,          ,     ,       ,          ,        )
nGVCRegGer 	:= aScan(aHeadGAVC,  {|aVet| aVet[2] == "GAV_REGGER"})
nGVCNome 	:= aScan(aHeadGAVC,  {|aVet| aVet[2] == "GAV_NOME  "})
nGVCCodLoc := aScan(aHeadGAVC,   {|aVet| aVet[2] == "GAV_CODLOC"})
nGVCCodQua := aScan(aHeadGAVC,   {|aVet| aVet[2] == "GAV_QUARTO"})
nGVCCodLei := aScan(aHeadGAVC,   {|aVet| aVet[2] == "GAV_LEITO "})
nGVCRegate := aScan(aHeadGAVC,   {|aVet| aVet[2] == "GAV_REGATE"})
nGVCDatInt := aScan(aHeadGAVC,   {|aVet| aVet[2] == "GAV_DATATE"})
nGVCCrm		:= aScan(aHeadGAVC,   {|aVet| aVet[2] == "GAV_CODCRM"})
nGVCIdade   := aScan(aHeadGAVC,   {|aVet| aVet[2] == "GAV_IDADE "})
nGVCReserv	:= aScan(aHeadGAVC,   {|aVet| aVet[2] == "GAV_RESERV"})

oGetGAVC := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], 0      ,"",,             ,,,       ,,,, oFolder:aDialogs[2], aHeadGAVC, aColsGAVC)
oGetGAVC:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
oGetGAVC:oBrowse:BlDblClick := {|| IIF(aScan(aHeadGAVC, {|aVet| aVet[2] == "GAV_REGGER"})>0,HS_HP14Tra(oGetGAVC,oFolder:nOption),.F.)}


//Posto Enfermagem
HS_BDados("GAV", @aHeadGAVP, @aColsGAVP,@nUGAVP,  1   ,        , "GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.GAV_STATUS IN ('1', '2', '3', '5') AND GAV.GAV_TIPO NOT IN ('2') AND GAV.GAV_REGGER NOT IN( SELECT GT6_REGGER  FROM " + RetSqlName("GT6") + " GT6 WHERE GT6.GT6_FILIAL = '" + xFilial("GT6") + "' AND GT6.D_E_L_E_T_ <> '*' )  OR  GAV_RESERV  IN ( '0', '1', '2', '3', '4', '5') ",        ,"GAV_STATUS",         ,        ,        ,        ,/*cCpoMark*/,/*cMarDef*/,  .t.      ,aCor,        ,         ,          ,          ,     ,       ,          ,        )
nGavRegGer := aScan(aHeadGAVP, {|aVet| aVet[2] == "GAV_REGGER"})
nGavNome := aScan(aHeadGAVP,   {|aVet| aVet[2] == "GAV_NOME  "})
nGavCodLoc := aScan(aHeadGAVP,   {|aVet| aVet[2] == "GAV_CODLOC"})
nGavCodQua := aScan(aHeadGAVP,   {|aVet| aVet[2] == "GAV_QUARTO"})
nGavCodLei := aScan(aHeadGAVP,   {|aVet| aVet[2] == "GAV_LEITO "})
nGavRegate := aScan(aHeadGAVP,   {|aVet| aVet[2] == "GAV_REGATE"})
nGavDatInt := aScan(aHeadGAVP,   {|aVet| aVet[2] == "GAV_DATATE"})
nGavCrm	   := aScan(aHeadGAVP,   {|aVet| aVet[2] == "GAV_CODCRM"})
nGavIdade  := aScan(aHeadGAVP,   {|aVet| aVet[2] == "GAV_IDADE "})
nGavReserv := aScan(aHeadGAVP,   {|aVet| aVet[2] == "GAV_RESERV"})

oGetGAVP := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], 0      ,"",,             ,,,       ,,,, oFolder:aDialogs[3], aHeadGAVP, aColsGAVP)
oGetGAVP:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
oGetGAVP:oBrowse:BlDblClick := {|| IIF(aScan(aHeadGAVP, {|aVet| aVet[2] == "GAV_REGGER"})>0,HS_HP14Tra(oGetGAVP,oFolder:nOption),.F.)}


aAdd(aButtons,	{"BR_VERDE_OCEAN", {|| Iif ( oFolder:noption==1 ,HS_M39Leg(), Iif ( oFolder:noption=3,HS_LegPos(), HS_M35LEG() ))}, STR0005,STR0005})  // //"Lengenda"###"Legenda"
aAdd(aButtons,	{"S4WB016N", {||HS_CfgMA7(),Fs_Atualiza(oGetGav)}, STR0006,STR0006})  // //"Confi.Campos Leito"###"Confi.Campos Leito"
aAdd(aButtons,  {"PMSRRFSH", {|| FS_Refresh()}, "Atualiza ","Atualiza"})

@ 019 , 005  Say STR0007  Size 80,20 Of oPaneL3 Pixel COLOR CLR_BLUE //"Lista de Espera"

///Legendas
@ 005, 005 BitMap NAME "BR_VERMELHO" SIZE 8, 8 NOBORDER Of oPaneL3 PIXEL
@ 005, 015 Say STR0008 Of oPaneL3 PIXEL // //"Urgencia/Emergencia"

@ 005, 070 BitMap NAME "BR_MARROM" SIZE 8, 8 NOBORDER Of oPaneL3 PIXEL
@ 005, 080 Say STR0009 Of oPaneL3 PIXEL //     //"UTI"

@ 005, 090 BitMap NAME "BR_PRETO" SIZE 8, 8 NOBORDER Of oPaneL3 PIXEL
@ 005, 100 Say STR0010 Of oPaneL3 PIXEL // //"Cirurgica"

@ 005, 125 BitMap NAME "BR_CINZA" SIZE 8, 8 NOBORDER Of oPaneL3 PIXEL
@ 005, 135 Say STR0011 Of oPaneL3 PIXEL //    */ //"Enfermagem"

@ 005, 170 BitMap NAME "BR_AMARELO" SIZE 8, 8 NOBORDER Of oPaneL3 PIXEL
@ 005, 180 Say STR0012 Of oPaneL3 PIXEL // //"Eletiva"

@ 005, 200 BitMap NAME "BR_BRANCO" SIZE 8, 8 NOBORDER Of oPaneL3 PIXEL
@ 005, 210 Say STR0013 Of oPaneL3 PIXEL //    */ //"Clinica"

ACTIVATE MSDIALOG oDlgAut ON INIT EnchoiceBar(oDlgAut, {|| nOpcAut := 1,oDlgAut:End()}, ;
{|| oDlgAut:End(), nOpcAut := 0},,aButtons)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHP04  บAutor  ณMicrosiga           บ Data ณ  11/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Exibe os Campos  Selecionados atraves da Rotina  de Configบฑฑ
ฑฑบ          ณ  Campos HS_CfgMA7()                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static  Function FS_ExibGav()
Local aCpoEnchoi := {}
Local cSql := ""
Local aArea := GetArea()

cSql := "SELECT GMT_CAMPO,GMT_ORDEM FROM "+RetSqlName("GMT")+" GMT WHERE GMT_FILIAL = '" + xFilial("GMT") + "' AND GMT.D_E_L_E_T_ <> '*' "
cSql += "AND GMT_CODLOC = '" +SPACE(LEN(GMT->GMT_CODLOC))+ "' AND GMT_MOSTRA = '1' AND GMT_TABELA = 'GAV' ORDER BY GMT_ORDEM"

cSql := ChangeQuery(cSql)
TCQuery cSql New Alias "TMPGMT"
DbSelectArea("TMPGMT")
While !EOF()
	If TMPGMT->GMT_CAMPO <> "GBH_BITMAP"
		AADD(aCpoEnchoi, TMPGMT->GMT_CAMPO)
	EndIf
	dbskip()
End
DBCloseArea()
RestArea(aArea)

Return(aCpoEnchoi)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHP04  บAutor  ณMicrosiga           บ Data ณ  11/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a Movimenta็ใo de leitos 						  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Fs_Atualiza()
Local aCampos:=FS_ExibGav()
oPaneL2:FreeChildren()
oGetGav:=HS_MBrow(oPaneL2, "GAV"    , {aPPac[1, 1], aPPac[1, 2], aPPac[1, 3], Iif(OAPP:LMDI,aPPac[1, 4]-25,aPPac[1, 4]-35)},        ,        ,        , aCorLeito,          ,         ,          ,          ,         , 	 ,       , 	 .F.     , aCampos      ,       ,       ,  aCampos           , .T.)
oGetGav:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHP04  บAutor  ณMicrosiga           บ Data ณ  11/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_HP14Tra(oObj,nOpt)
Local aArea := GetArea()
Local oDlgTra
Local nOpcTra := 0
Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {}
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

Local aCpoGt6 	:= { "GT6_REGGER","GT6_NOME", "GT6_CODLOC", "GT6_QUARTO", "GT6_LEITO","GT6_TPRESE" }
Local lAcha		:= .F.
Local cNome		:= ""
Local cProntu	:= ""
Local cCodage 	:= ""
Local cIdade	:= ""
Local cSetoOrige:= ""
Local cQuarOrige:= ""
Local cLeitOrige:= ""
Local cPlanoPac	:= ""
Local cRegate	:= ""
Local cReserv	:= ""

Private  aGets 	:= {} , aTela:= {}

If nOpt==1    // verifica as Op็๕es do Folter para exibiใo dos Dados
	cProntu    := oObj:aCols[oObj:oBrowse:nAt,nGMJRegGer]
	cNome      := oObj:aCols[oObj:oBrowse:nAt,nGMJNome]
	cCodage    := oObj:aCols[oObj:oBrowse:nAt,nGMJCodAge]
	cSetoOrige := oObj:aCols[oObj:oBrowse:nAt,nGMJCodLoc] //setor origem
	cQuarOrige := oObj:aCols[oObj:oBrowse:nAt,nGMJCodQua] //quarto Origem
	cRegate	   := oObj:aCols[oObj:oBrowse:nAt,nGMJRegAte] //quarto Origem
	
	Inclui 	   := .F.
	cIdade     := HS_M33Age( oObj:aCols[oObj:oBrowse:nAt,nGMJRegGer] )  // carregar a idade conforme padrao para a GAV 99a99m99d
	Inclui 	   := .T.
	
ElseIf nOpt==2
	cProntu		:=oObj:aCols[oObj:oBrowse:nAt,nGVCRegGer]
	cNome  		:=oObj:aCols[oObj:oBrowse:nAt,nGVCNome]
	cIdade   	:=oObj:aCols[oObj:oBrowse:nAt,nGVCIdade]
	cSetoOrige 	:=oObj:aCols[oObj:oBrowse:nAt,nGVCCodLoc]
	cQuarOrige 	:=oObj:aCols[oObj:oBrowse:nAt,nGVCCodQua] //quarto Origem
	cLeitOrige 	:=oObj:aCols[oObj:oBrowse:nAt,nGVCCodLei] // Leito Origem
	cRegate 	:=oObj:aCols[oObj:oBrowse:nAt,nGVCRegate] // Leito Origem 
	cReserv     :=oObj:aCols[oObj:oBrowse:nAt,nGVCReserv]
	
Elseif nOpt==3
	cProntu		:=oObj:aCols[oObj:oBrowse:nAt,nGavRegGer]
	cNome  		:=oObj:aCols[oObj:oBrowse:nAt,nGavNome]
	cIdade   	:=oObj:aCols[oObj:oBrowse:nAt,nGavIdade]
	cSetoOrige 	:=oObj:aCols[oObj:oBrowse:nAt,nGavCodLoc]
	cQuarOrige 	:=oObj:aCols[oObj:oBrowse:nAt,nGavCodQua] //quarto Origem
	cLeitOrige 	:=oObj:aCols[oObj:oBrowse:nAt,nGavCodLei] // Leito Origem 
	cRegate 	:=oObj:aCols[oObj:oBrowse:nAt,nGavRegate] // Leito Origem
	cReserv     :=oObj:aCols[oObj:oBrowse:nAt,nGavReserv]
	
Else
	cProntu		:=oObj:aCols[oObj:oBrowse:nAt,nGT6RegGer]
	cNome  		:=oObj:aCols[oObj:oBrowse:nAt,nGT6Nome]
	
Endif


aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

If nHRes <= 969	// Resolucao 1280x1024
	DEFINE MSDIALOG oDlgTra TITLE STR0001 From aSize[ 7 ], 000 To aSize[ 6 ]/2.65/*210*/, (aSize[ 5 ]/1.3)/*390*/	Of oMainWnd Pixel //"Transferencia de despesas entre guias de mesmo atendimento" //"Reserva de Leitos"
Else
	DEFINE MSDIALOG oDlgTra TITLE STR0001 From aSize[ 7 ], 000 To aSize[ 6 ]/3.5/*210*/, (aSize[ 5 ]/1.75)/*390*/	Of oMainWnd Pixel //"Transferencia de despesas entre guias de mesmo atendimento" //"Reserva de Leitos"
Endif
//////DEFINE MSDIALOG oDlgTra TITLE "Reserva de Leitos" From aSize[ 7 ], 000 To aSize[ 6 ]/*210*/, (aSize[ 5 ])/*390*/	Of oMainWnd Pixel //"Transferencia de despesas entre guias de mesmo atendimento"

RegToMemory("GT6", .F.)
DbSelectArea("GT6")

	DbSetOrder(2)
	lAcha:=DbSeek(xFilial("GT6") + cProntu + cNome )

If  lAcha
	nReg 	:= GT6->(Recno())
	Inclui 	:= .F.
Else
	nReg	:= 0
	Inclui 	:= .T.
EndIf

RegToMemory("GT6",(nReg == 0)) //Gera variavies de memoria para o GPE

M->GT6_REGGER := cProntu
M->GT6_NOME := cNome
M->GT6_CODAGE :=cCodage
M->GT6_IDADE	:=	cIdade

oEncGta := MsMGet():New("GT6", 0, 3,,,, /*aCpoGt6*/, {aPObjs[1, 2], aPObjs[1, 2], aPObjs[1, 1], aPObjs[1, 3]},/* aCpoAlt*/, ,,,, oDlgTra,, .T.,,,,,, .T.)
oEncGta:oBox:Align := CONTROL_ALIGN_ALLCLIENT


ACTIVATE MSDIALOG oDlgTra CENTERED ON INIT EnchoiceBar(oDlgTra, {|| nOpcTra := 1,IIF(Obrigatorio(aGets, aTela),oDlgTra:End() ,nOpcAut := 0)}, ;
{|| oDlgTra:End(), nOpcTra := 0})

If nOpcTra == 1
	Begin Transaction
	If  nOpt <> 0
		FS_GRVESP(cProntu,cIdade,cSetoOrige,cQuarOrige,cLeitOrige,cRegate,cReserv)
	Else
		HS_ExclEs(cProntu)
	Endif
	End Transaction
	
	FS_Refresh()
	
EndIf

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVRESP บAutor  ณ			     บ Data ณ 18/10/10   		บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para gravar a Fila de Espera dos Setores/Quartos/Leitosบฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GRVESP(cProntu,cIdade,cSetoOrige,cQuarOrige,cLeitOrige,cRegate,cReserv)
Local aArea 	:= GetArea()
Local aVSus   	:= {GETMV("MV_PCONSUS"), GETMV("MV_PSUSBPA"), GETMV("MV_PSUSPAC"), GETMV("MV_PSUSAIH")}
Local cConPropr := GetNewPar("MV_CONVPLS", "001")
DEFAULT cProntu :=""
DEFAULT cIdade	:=""
DEFAULT cSetoOrige	:=""
DEFAULT cQuarOrige	:=""
DEFAULT cLeitOrige	:=""
DEFAULT cRegate	:=""
DEFAULT cReserv	:=""  

//Verifica se e RN
DbSelectArea("GB2")
DbSetOrder(1)
If DbSeek(xFilial("GB2") +cRegate+cReserv )
	HS_MsgInf(STR0022, STR0015, STR0016) //"RN deve ser cadastrado como paciente para admissใo no Centro Cirดrgico."###"Atencao"###"Admissao Centro Cirurgico"
	RestArea(aArea)
	Return(nil)
Endif

If Empty(M->GT6_REGGER)
	HS_MSGINF(STR0021,STR0015,STR0016)//"Paciente sem Prontuario para a Reserva de Leito" "Aten็ใo" "Valida็ใo Lista Espera."
	Return(nil)
Endif

DbSelectArea("GT5")
DbSetOrder(1)

If GT5->(DbSeek(xFilial("GT5") + M->GT6_CODLOC+M->GT6_QUARTO+M->GT6_LEITO))
	DbSelectArea("GT6")
	DbSetOrder(1)
	RecLock("GT6", .T.)
	HS_GrvCpo("GT6")
	GT6->GT6_FILIAL  := xFilial("GT6")
	GT6->GT6_IDADE 	  :=cIdade
	
	DbSelectArea("GCS")
	DbSetOrder(1) // GCS_FILIAL + GCS_CODLOC
	If DbSeek(xFilial("GCS") + cSetoOrige)
		If GCS->GCS_TIPLOC == "4"
			GT6->GT6_TIPLOC :="0"
		Elseif 	GCS->GCS_TIPLOC == "3"
			
			DbSelectArea("GAV")
			DbSetOrder(1)
			If DbSeek(xFilial("GAV") + cSetoOrige + cQuarOrige + cLeitOrige )
				If GAV->GAV_TIPO == "4"
					GT6->GT6_TIPLOC := "1"
				Else
					GT6->GT6_TIPLOC := "2"
				Endif
			Endif
		Elseif 	GCS->GCS_TIPLOC == "8"
			GT6->GT6_TIPLOC := "3"
		Elseif 	GCS->GCS_TIPLOC == "B"
			GT6->GT6_TIPLOC := "4"
		Endif
	Endif
	
	DbSelectArea("GD4")
	DbSetOrder(2)
	If DbSeek(xFilial("GD4") + cProntu + "1")
		If GetMV("MV_PLANPAR") == GD4->GD4_CODPLA  // particular
			GT6->GT6_TIPCON:="0"
		ElseIf aVSus[1] == HS_IniPadr("GCM", 2, GD4->GD4_CODPLA, "GCM_CODCON",, .F.)  // SUS
			GT6->GT6_TIPCON:="3"
		ElseIf  cConPropr == HS_IniPadr("GCM", 2, GD4->GD4_CODPLA, "GCM_CODCON",, .F.)	//rede Propria
			GT6->GT6_TIPCON:="2"
		Else
			GT6->GT6_TIPCON:="1"     //Convenios
		Endif
	Endif
	
	MsUnLock()
Endif

RestArea(aArea)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ExbLsE บAutor  ณ				    บ Data ณ  12/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณExibe a Lista de Espera de Pacientes na Interna็ใo          บฑฑ
ฑฑบ			 ณUtilizada Rotina M30 M35 e M24							  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_ExbLsE(cSetor,cQuart,cLeito,nOpcPst)
Local aArea 	:= GetArea()
Local aSize 	:= {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local cOrdGT6 	:='GT6_CODLOC,GT6_TPRESE'
Local  aJoinGT6 := {{     " JOIN " + RetSqlName("GT5") + " GT5 ", " " , "GT5.GT5_FILIAL = '" + xFilial("GT5") + "' AND GT5.D_E_L_E_T_ <> '*' AND GT5.GT5_CODLOC = GT6.GT6_CODLOC AND GT5.GT5_QUARTO = GT6.GT6_QUARTO AND GT5.GT5_LEITO = GT6.GT6_LEITO  ", " "}}
Local LExib		:=	.F.
Local lRet		:=.F.
Local nPosItem	:=0
Local  cCond	:=""

Private nUGT6		:= 0
Private nGT6Regger  :=0
Private nGT6CodLoc := 0
Private nGT6CodQua := 0
Private nGT6CodLei := 0
Private nGT6Nome	:= 0
Private nGT6Codage	:= 0
Private nGT6IDADE  	:= 0
Private nGT6TIPLOC  := 0
Private nGT6TIPCON  := 0

Private cRegger	  	:= ""
Private cnome	  	:= ""
Private cCodAge	  	:= ""
Private nOpcRev 	:= 0
Private nGT6IdOK	:= 0
Private cPacHSP04 	:= ""
Private aHeadGT6 	:= {}, aColsGT6 := {}
Private oGetGT6	:= nil
Private aHeadGT5 	:= {}, aColsGT5 := {}
Private oGetGT5		:= nil
Private nGT5CODLOC	:= 0
Private nGT5QUARTO	:= 0
Private nGT5LEITO	:= 0
Private nGT5TPRESE	:= 0
Private nGT5PSETOR	:= 0
Private nGT5PIDADE	:= 0
Private nGT5PREINT	:= 0
Private nGT5PDATA 	:= 0
Private nGT5PLEIES	:= 0
Private nGT5PTIPO 	:= 0
Private nGT5CID   	:= 0
Private nUGT5		:= 0
Private oDlgp04
Private chsp04Tran	:=""

Private	aCorPrio := {{"GT6_TPRESE == '0'  " 	  , "BR_VERMELHO"},;
{"GT6_TPRESE == '1'"                              , "BR_MARROM" },;
{"GT6_TPRESE == '2'"                              , "BR_PRETO"  },;
{"GT6_TPRESE == '3'"                              , "BR_CINZA"  },;
{"GT6_TPRESE == '4'"                              , "BR_AMARELO"},;
{"GT6_TPRESE == '5'"                              , "BR_BRANCO"  }}

Default cSetor		:=""
Default cQuart		:=""
Default cLeito		:=""
Default nOpcPst		:=0
INCLUI:=.F.

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd(aObjects, {100, 100, .T., .T.})

aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T.)



DEFINE MSDIALOG oDlgp04 TITLE OemToAnsi(STR0007 ) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL //"Lista de espera //"Lista de Espera"


cCond := " GT6.GT6_FILIAL = '" + xFilial("GT6") + "' AND GT6.GT6_CODLOC='"+cSetor+"'  AND GT6.GT6_QUARTO='"+cQuart+"'  AND GT6.GT6_LEITO='"+cLeito+"' AND  GT6.D_E_L_E_T_<>'*'  "

If Type("cPacHSP04") <> "U" .And.  FunName() $ "HSPM24AI"
	cCond += "   AND  GT6_CODAGE <> '" + Space(TamSx3("GT6_CODAGE")[1]) + "'  "
EndIf

HS_BDados("GT5" , @aHeadGT5 , @aColsGT5 , @nUGT5  , 1   ,         ,"GT5.GT5_FILIAL = '" + xFilial("GT5") + "' AND  GT5.D_E_L_E_T_<>'*' "								 																																																												  ,         ,                      ,         ,         ,        ,        ,       																																			,        																																			, .T.    ,         ,        ,         ,           ,  		 , /*aCposVis*/ ,           ,          , 		,/*aCposVis*/)
nGT5CODLOC	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_CODLOC"})
nGT5QUARTO	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_QUARTO"})
nGT5LEITO	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_LEITO "})
nGT5TPRESE 	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_TPRESE"})
nGT5PSETOR	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PSETOR"})
nGT5PIDADE	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PIDADE"})
nGT5PREINT	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PREINT"})
nGT5PDATA 	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PDATA "})
nGT5PLEIES	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PLEIES"})
nGT5PTIPO 	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_PTIPO "})
nGT5CID   	:= aScan(aHeadGT5,   {|aVet| aVet[2] == "GT5_CID   "})

HS_BDados("GT6", @aHeadGT6, @aColsGT6, @nUGT6   , 1,        , cCond																												                                                                 ,        , "GT6_TPRESE"         ,         ,         ,        ,        ,IIF((FunName() $ "HSPAHM30" .and. nOpcPst ==5) .or. (FunName() $"HSPM24AI") .or. ( FunName() $"HSPAHM35".and.nOpcPst <>2) , {"GT6_OK    "}, ),IIF((FunName() $ "HSPAHM30" .and. nOpcPst ==5) .or. FunName() $"HSPM24AI/HSPAHM35" .or. ( FunName() $"HSPAHM35".and.nOpcPst <>2) ,{"'LBNO'"}, ),            , aCorPrio,        ,   /*.T.*/       ,           ,         ,         ,aJoinGT6  ,          , cOrdGT6    ,)
nGT6REGGER := aScan(aHeadGT6,   {|aVet| aVet[2] == "GT6_REGGER"})
nGT6NOME   := aScan(aHeadGT6,   {|aVet| aVet[2] == "GT6_NOME  "})
nGT6CodLoc := aScan(aHeadGT6,   {|aVet| aVet[2] == "GT6_CODLOC"})
nGT6CodQua := aScan(aHeadGT6,   {|aVet| aVet[2] == "GT6_QUARTO"})
nGT6CodLei := aScan(aHeadGT6,   {|aVet| aVet[2] == "GT6_LEITO "})
nGT6Codage := aScan(aHeadGT6,   {|aVet| aVet[2] == "GT6_CODAGE"})
nGT6IdOK   := aScan(aHeadGT6,   {|aVet| aVet[2] == "GT6_OK    "})
nGT6IDADE  := aScan(aHeadGT6,   {|aVet| aVet[2] == "GT6_IDADE "})
nGT6TIPLOC := aScan(aHeadGT6,   {|aVet| aVet[2] == "GT6_TIPLOC"})
nGT6TIPCON := aScan(aHeadGT6,   {|aVet| aVet[2] == "GT6_TIPCON"})
nGT6TPrese	:= aScan(aHeadGT6,  {|aVet| aVet[2] == "GT6_TPRESE"})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็ใo que Realiza a Atualiza็ใo da Ordem na Lista de espera    ณ
//ณconforme Setor Parametrizado                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF((FunName() $ "HSPAHM30" .and. nOpcPst ==5) .or. (FunName() $"HSPM24AI") .or. ( FunName() $"HSPAHM35".and.nOpcPst <>2))
LExib:=.T.
Endif

If !Empty(aColsGT6[1,nGT6CodLoc])
	Fs_ordem(aColsGT6,aColsGT5,LExib)
Endif


oGetGT6 := MsNewGetDados():New(aPObjs[1, 1] , aPObjs[1, 2] , aPObjs[1, 3] , aPObjs[1, 4] , 0      ,,,             ,,,      ,,,, oDlgp04, aHeadGT6, aColsGT6)
oGetGT6:oBrowse:BlDblClick := {|| FS_DblClk(oGetGT6:oBrowse:nAt)}
oGetGT6:oBrowse:Align 	:= CONTROL_ALIGN_BOTTOM


ACTIVATE MSDIALOG oDlgp04 CENTERED ON INIT EnchoiceBar(oDlgp04, {|| nOpcRev := 1, oDlgp04:End()}, ;
{|| nOpcRev := 0, oDlgp04:End()})


If nOpcRev == 1  .AND. nGT6IdOK <> 0
	If FunName() == "HSPM24AI"  .or. (FunName() == "HSPAHM30" .AND. nOpcPst==5 )
		DbSelectArea("GT6")
		GT6->(DbSetOrder(2))
		If GT6->(DbSeek(xFilial("GT6")+cRegger))
			cCodAge:=GT6->GT6_CODAGE
			RestArea(aArea)
			Return({cRegger,cNome,cSetor,cQuart,cLeito,cCodAge}) // retorna um array para quando for transferencia no centro cirurgico
		Endif
		
	Endif
Else
	__ReadVar := ""
EndIf


RestArea(aArea)

Return(cRegger,cNome,cSetor,cQuart,cLeito,cCodAge)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DbLClikบAutor  ณSaude               บ Data ณ 02/12/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para marcar e desmarcar o item do Grid               บฑฑ
ฑฑบ          ณE marcar os itens do Grid dos itens                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DblClk(nMar)
Local nForACols := 0

If oGetGT6:aHeader[oGetGT6:oBrowse:nColPos, 2] == "GT6_OK    " //.AND. !oGetGAV:aCols[nMar,nUGPG+1]
	If oGetGT6:aCols[nMar,nGT6IdOK] == "LBNO"
		oGetGT6:aCols[nMar,nGT6IdOK] := "LBTIK"
		For nForACols := 1 to len(oGetGT6:aCols)
			If oGetGT6:aCols[nForACols,nGT6IdOK] == "LBTIK" .And. nForACols <> nMar
				oGetGT6:aCols[nForACols,nGT6IdOK] := "LBNO"
				Exit
			Endif
		Next
	Endif
Else
	oGetGT6:EDITCELL( oGetGT6:OBROWSE, oGetGT6:oBrowse:nAt, oGetGT6:oBrowse:nColPos )
EndIf
oGetGT6:oBrowse:Refresh()
cRegger:=oGetGT6:aCols[nMar,nGT6Regger]
cnome:=oGetGT6:aCols[nMar,nGT6Nome]

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ExclEs  บAutor  ณMicrosiga           บ Data ณ  12/02/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para quando for realizado a Recep็ใo de pacientes em บฑฑ
ฑฑบ          ณlista de espera o mesmo seja retirado da Fila de espera     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_ExclEs(cProntuario)
Local aArea := GetArea()

DbSelectArea("GT6")
DbSetOrder(2)
lAchou := GT6->(DbSeek(xFilial("GT6") + cProntuario))
If lAchou
	RecLock("GT6", .F., .F.)
	DbDelete()
	MsUnlock()
	WriteSx2("GT6")
Else
	Return(nil)
EndIf

RestArea(aArea)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldP04 บAutor  ณMicrosiga           บ Data ณ  01/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo dos  campos da Movimenta็ใo dos leitos            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_VldP04()

Local lRet := .T.
Local cAliasOld := Alias()
Local cSexoQuarto:=""

If ReadVar() == "M->GT6_CODLOC"
	If Empty(M->GT6_CODLOC) .Or. !HS_SeekRet("GT5","M->GT6_CODLOC", 1, .F.)
		HS_MsgInf(STR0017, STR0016, STR0001) //"C๓digo do setor invแlido"###"Aten็ใo"###"Reserva de Leitos" //"Nใo existe Parametriza็ใo para o Setor Informado"###"Aten็ใo"###"Reserva de Leitos"
		lRet := .F.
	Endif
	
ElseIf ReadVar() == "M->GT6_QUARTO"
	
	If !HS_SeekRet("GT5","M->GT6_CODLOC+M->GT6_QUARTO", 1, .F.)
		HS_MsgInf(STR0018, STR0016, STR0001) //"C๓digo do setor invแlido"###"Aten็ใo"###"Reserva de Leitos" //"Nใo existe Parametriza็ใo para o Quarto Informado"###"Aten็ใo"###"Reserva de Leitos"
		lRet := .F.
	Endif
	
	If Empty(M->GT6_CODLOC)
		HS_MsgInf(STR0019, STR0016, STR0001)     //"Por favor, informe o c๓digo do setor"###"Aten็ใo"###"Reserva de Leitos" //"Por favor, informe o c๓digo do setor"###"Aten็ใo"###"Reserva de Leitos"
		lRet := .F.
	EndIf
	
	cSexoQuarto := HS_Sexo_Quarto(M->GT6_CODLOC, M->GT6_QUARTO)
	If !Empty(cSexoQuarto) .And. cSexoQuarto != "2" .And. cSexoQuarto != HS_IniPadr("GBH", 1, M->GT6_REGGER, "GBH_SEXO",,.F.)
		HS_MsgInf(STR0020 + X3COMBO("GAV_SEXO", cSexoQuarto), STR0016, STR0001) //"Quarto invแlido - jแ ocupado por paciente de sexo "###"Aten็ใo"###"Valida็ใo do sexo do paciente" //"Quarto de reserva para  Sexo "###"Aten็ใo"###"Reserva de Leitos"
		Return(.F.)
	Endif
Endif
DbSelectArea(cAliasOld)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RefreshบAutor  ณSaude               บ Data ณ  01/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza็ใo das Grids de Agenda Centro Cirurgico,Posto Enf บฑฑ
ฑฑบ          ณ ermagem e Centro Cirurgico                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function  FS_Refresh()
Local cOrdGT6 :='GT6_CODLOC,GT6_TPRESE'
Inclui:=.f.

aHeadGMJ:={}
aColsGMJ:={}
HS_BDados("GMJ", @aHeadGMJ , @aColsGMJ ,   , 1   ,        , "GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.GMJ_DATAGE >= '" + DToS(dDataBase) + "' AND (GMJ.GMJ_STATUS = '1' OR GMJ.GMJ_STATUS = '3') AND GMJ.GMJ_CODAGE = GMJ.GMJ_SEQAGE  AND GMJ.GMJ_REGGER  NOT IN ( SELECT GT6_REGGER  FROM " + RetSqlName("GT6") + " GT6 WHERE GT6.GT6_FILIAL = '" + xFilial("GT6") + "' AND GT6.D_E_L_E_T_ <> '*' )",         ,"GMJ_STATUS",         ,        ,        ,         ,        ,        ,   .t.     ,aCorM39  ,        ,         ,           ,         ,         ,            ,          ,        ,          ,)
oGetGMJ:SetArray(aColsGMJ)
oGetGMJ:oBrowse:Refresh()

aHeadGT5:={}
aColsGT5:={}

HS_BDados("GT5", @aHeadGT5 , @aColsGT5 ,     , 1   ,        ,"GT5.GT5_FILIAL = '" + xFilial("GT5") + "' AND  GT5.D_E_L_E_T_<>'*' "								 																																																												  ,         ,                      ,         ,         ,        ,        ,                                                                                                                                                 ,                                                                                                                                                   , .T.    ,         ,        ,         ,           ,  		 ,              ,           ,          ,        ,            )

aHeadGT6:={}
aColsGT6:={}
HS_BDados("GT6" , @aHeadGT6, @aColsGT6  ,    , 1   ,         ,"GT6.GT6_FILIAL = '" + xFilial("GT6") + "' AND  GT6.D_E_L_E_T_<>'*' "																												 ,        , "GT6_TPRESE"         ,         ,         ,        ,        ,        ,        ,  /*.T. */  , aCorPrio,        ,   /*.T.*/   ,           ,         ,         ,aJoinGT6  ,          , cOrdGT6,)

If !Empty(aColsGT6[1,nGT6CodLoc])
	Fs_ordem(aColsGT6,aColsGT5)
Endif


oGetGT6:SetArray(aColsGT6)
oGetGT6:oBrowse:Refresh()

aHeadGAVC:={}
aColsGAVC:={}
HS_BDados("GAV", @aHeadGAVC, @aColsGAVC, ,  1   ,        , "GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.GAV_STATUS = '1' AND GAV.GAV_REGGER NOT IN( SELECT GT6_REGGER  FROM " + RetSqlName("GT6") + " GT6 WHERE GT6.GT6_FILIAL = '" + xFilial("GT6") + "' AND GT6.D_E_L_E_T_ <> '*'  ) OR  GAV_RESERV  IN ( '0', '1', '2', '3', '4', '5')  ",        ,"GAV_STATUS",         ,        ,        ,        ,/*cCpoMark*/,/*cMarDef*/,     .T.   ,aCorM35,        ,         ,          ,          ,     ,       ,          ,        )
oGetGAVC:SetArray(aColsGAVC)
oGetGAVC:oBrowse:Refresh()

aHeadGAVP:={}
aColsGAVP:={}
HS_BDados("GAV", @aHeadGAVP, @aColsGAVP, ,  1   ,        , "GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.GAV_STATUS IN ('1', '2', '3', '5') AND GAV.GAV_TIPO NOT IN ('2') AND  GAV.GAV_REGGER NOT IN( SELECT GT6_REGGER  FROM " + RetSqlName("GT6") + " GT6 WHERE GT6.GT6_FILIAL = '" + xFilial("GT6") + "' AND GT6.D_E_L_E_T_ <> '*'  )  OR  GAV_RESERV  IN ( '0', '1', '2', '3', '4', '5') ",        ,"GAV_STATUS",         ,        ,        ,        ,/*cCpoMark*/,/*cMarDef*/,     .T.   ,aCor,        ,         ,          ,          ,     ,       ,          ,        )
oGetGAVP:SetArray(aColsGAVP)
oGetGAVP:oBrowse:Refresh()

Inclui:=.T.
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFs_ordem  บAutor  ณMicrosiga           บ Data ณ  02/22/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para ordernar o Conteudo da Lista de Espera conforme บฑฑ
ฑฑบ          ณparametriza็ใo de Cada Leito/Setor na Tabela GT5            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Fs_ordem(aColsG6,aColsG5,LExib)
Local aCAux := {},aCAux1 := {}
Local nFor,nFor2,nI,ni2,ni3 := 0
Local cCodLoc := ""
Local ccorLeg :=  ""
Default LExib:=.F.

For nFor2 := 1 to len(aColsG5)
	For nFor := 1 to len(aColsG6)
		If aColsG5[nFor2,nGT5CODLOC] == aColsG6[nFor,nGT6CodLoc] .and. aColsG5[nFor2,nGT5QUARTO] == aColsG6[nFor,nGT6CodQua] .AND.  aColsG5[nFor2,nGT5LEITO] == aColsG6[nFor,nGT6CodLei]
			
			IF aColsG6[nFor, nGT6TPrese]=="BR_VERMELHO"
				aColsG6[nFor, nGT6TPrese]:='0'
			Elseif	aColsG6[nFor, nGT6TPrese]=="BR_MARROM"
				aColsG6[nFor, nGT6TPrese]:='1'
			Elseif	aColsG6[nFor, nGT6TPrese]=="BR_PRETO"
				aColsG6[nFor, nGT6TPrese]:='2'
			Elseif	aColsG6[nFor, nGT6TPrese]=="BR_CINZA"
				aColsG6[nFor, nGT6TPrese]:='3'
			Elseif	aColsG6[nFor, nGT6TPrese]=="BR_AMARELO"
				aColsG6[nFor, nGT6TPrese]:='4'
			ElseIF aColsG6[nFor, nGT6TPrese]=="BR_BRANCO"
				aColsG6[nFor, nGT6TPrese]:='5'
			Endif
			
			If LExib
				aAdd(aCAux, {aColsG6[nFor, nGT6TPrese],"LBNO",aColsG6[nFor, nGT6RegGer],aColsG6[nFor, nGT6Nome],aColsG6[nFor, nGT6CodLoc],aColsG6[nFor, nGT6CodQua],aColsG6[nFor, nGT6CodLei],aColsG6[nFor, nGT6IDADE],aColsG6[nFor, nGT6TipLoc],aColsG6[nFor, nGT6TIPCON],.F.   })
			Else
				aAdd(aCAux, {aColsG6[nFor, nGT6TPrese],aColsG6[nFor, nGT6RegGer],aColsG6[nFor, nGT6Nome],aColsG6[nFor, nGT6CodLoc],aColsG6[nFor, nGT6CodQua],aColsG6[nFor, nGT6CodLei],aColsG6[nFor, nGT6IDADE],aColsG6[nFor, nGT6TipLoc],aColsG6[nFor, nGT6TIPCON],.F.   })
			Endif
			
			If  aColsG5[nFor2,6] <> '9'
				aSort(aCAux,,, {|x,y| If(x[nGT6TipLoc] == aColsG5[nFor2,6], '0'+ x[nGT6TipLoc],'1'+ x[nGT6TipLoc]) > If(y[nGT6TipLoc] == aColsG5[nFor2,6], '0'+ y[nGT6TipLoc],'1'+ y[nGT6TipLoc]) })  // Organiza  por  Tipo de Local de Atendimento
			ElseIf aColsG5[nFor2,7] == '1'
				aSort(aCAux,,, {|x,y| x[nGT6CodLoc]  + x[nGT6IDADE]   < y[nGT6CodLoc]  + y[nGT6IDADE]     })  // Organiza por IDADE /Menor idade
				aSort(aCAux,,, {|x,y| x[nGT6TPrese] < y[nGT6TPrese]     })
			ElseIf aColsG5[nFor2,7] == '0'
				aSort(aCAux,,, {|x,y| x[nGT6CodLoc]  + x[nGT6IDADE]   > y[nGT6CodLoc]  + y[nGT6IDADE]  })  // Organiza por IDADE /Maior Idade
				aSort(aCAux,,, {|x,y| x[nGT6TPrese] < y[nGT6TPrese]     })
			ElseIf aColsG5[nFor2,11] <> '9'
				aSort(aCAux,,, {|x,y| If(x[nGT6TIPCON] == aColsG5[nFor2,11], '0'+ x[nGT6TIPCON],'1'+ x[nGT6TIPCON]) > If(y[nGT6TIPCON] == aColsG5[nFor2,11], '0'+ y[nGT6TIPCON],'1'+ y[nGT6TIPCON]) })  // Organiza  por Tipo de Convenio
			Endif
		Endif
	Next nFor
next nFor2

aSort(aCAux,,, {|x,y| x[nGT6TPrese] < y[nGT6TPrese]     })



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ8ฟ
//ณRetorna a Legenda apos Organiza็ใo de Dados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ8ู


For ni3 :=1 to len(aCAux)
	IF aCAux[ni3, nGT6TPrese]== '0'
		aCAux[ni3, nGT6TPrese]:="BR_VERMELHO"
	Elseif	aCAux[ni3, nGT6TPrese]== '1'
		aCAux[ni3, nGT6TPrese]:="BR_MARROM"
	Elseif	aCAux[ni3, nGT6TPrese]=='2'
		aCAux[ni3, nGT6TPrese]:="BR_PRETO"
	Elseif	aCAux[ni3, nGT6TPrese]== '3'
		aCAux[ni3, nGT6TPrese]:="BR_CINZA"
	Elseif	aCAux[ni3, nGT6TPrese]=='4'
		aCAux[ni3, nGT6TPrese]:="BR_AMARELO"
	Elseif	aCAux[ni3, nGT6TPrese]=='5'
		aCAux[ni3, nGT6TPrese]:="BR_BRANCO"
	Endif
	
next ni3


aColsG6 := aCAux

Return()





