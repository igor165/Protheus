#INCLUDE "HSPAHABQ.ch"
#include "protheus.CH"
#INCLUDE "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                                             
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHABQ  บ Autor ณ Mario Arizono      บ Data ณ  09/05/07   บฑฑ                                            
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Prescricao Medica                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHABQ()  
 Local aVerTab := {{"T", "GHV"},;
                   {"T", "GHX"},;   
                   {"C", "GHV_CODCRM"},; 
                   {"C", "GHV_NOMMED"},;
                   {"C", "GHV_USUSUS"},;
                   {"C", "GHV_DATSUS"},;  
                   {"C", "GHV_HORSUS"},;
                   {"C", "GHV_IMPVIA"},;
                   {"C", "GHV_RESERV"},;
                   {"C", "GHX_CDMEDI"},;
                   {"C", "GHX_DSITEM"},;
                   {"C", "GHX_APRESD"},;
                   {"C", "GHX_CDITPO"},;
                   {"C", "GHX_CDFRQA"},;
                   {"C", "GHX_DSFRQA"},;
                   {"C", "GHX_CDITUC"},;
                   {"C", "GHX_CDUNIC"},;
                   {"C", "GHX_DUNICO"},;
                   {"C", "GHX_DISPAR"},;
                   {"C", "GHX_IDREGI"},;
                   {"C", "GHX_OBSREG"},;
                   {"C", "GHX_OBSERV"},;
                   {"C", "GHX_USUSUS"},;
                   {"C", "GHX_DATSUS"},;  
                   {"C", "GHX_HORSUS"},;
                   {"C", "GHX_SEQITE"},;
                   {"C", "GHX_VOLUME"},;
                   {"C", "GHX_CODVIA"},;  
                   {"C", "GHX_DESVIA"},;
                   {"C", "GHX_CDMINF"},;
                   {"C", "GHX_DSMINF"},;
                   {"C", "GHX_VELINF"},;
                   {"C", "GHX_QTDMED"},;
                   {"C", "GHX_CODKIT"},;
                   {"C", "GHX_TPUSUA"},;
                   {"C", "GHX_STAENF"},;
                   {"C", "GHX_ITEGAJ"},;
                   {"C", "GHX_SEQDES"},;
                   {"C", "GDY_VOLUME"}}

 
 Private cCadastro := STR0001 //"Cadastro de Prescricao Medica"
 Private aRotina   := {{ OemToAnsi(STR0002)  ,"HS_MntAbq"		, 0 , 4},;//"Prescrever"
					   { OemToAnsi(STR0003)  ,"HS_MntAbq"		, 0 , 2},;//"Consultar"
                       { OemToAnsi(STR0004)  ,"HS_PacAbq"		, 0 , 4},;//"Paciente"
                       { OemToAnsi(STR0005)  ,"HSPAHR22({})"	, 0 , 3}} //"Impressใo"
                                               

 Private cFilAbq    := ""
   
 If !HS_EXISDIC(aVerTab)
  Return()
 Endif 
 
  /* Verificar autorizacao de acesso para o medico */
	If !(aCodUsr := HS_VldDAnm(,.F.))[1]
	 Return(Nil)
	EndIf
 
  
 DbSelectArea("GCY")
 DbSetOrder(1)
 
 If FS_FilABQ("HSPABQ", .F.)     
  SetKey(VK_F12, {|| FS_FilABQ("HSPABQ", .T.) }) 
  mBrowse(06, 01, 22, 75, "GCY",,,,,,,,,,,,,, cFilAbq)
 EndIf 

 SetKey(VK_F12)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ HS_MntAbqณ Autor ณ Mario Arizono         ณ Data ณ10/05/2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Montagem das rotinas de tratamento da Presc. Medica        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_MntAbq(cAlias, nReg, nOpc, aCposBrw, cTpNasc)
 
 Local nOpcGhv := 0
 Local cSeqPre := ""
 Local nOpcGhx := IIF(StrZero(aRotina[nOpc, 4], 2) $ "04", GD_DELETE, 0)
 Local nOpcA := 0
 Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPEnc := {}
 Local aCposAlt := {}, aCposObr := {}, aCposGcy := {}
 Local bFS_Inclui := {||FS_TratFun("1", nOpc, cSeqPre)} // Inclusao da prescricao
 Local bFS_IncPre	:= {||FS_TratFun("7", nOpc)} // Incluir item prescricao
 Local bFS_Copiar	:= {||FS_TratFun("2", nOpc, cSeqPre)} // Copiar prescricao
 Local bFS_Suspen	:= {||FS_TratFun("3", nOpc)} // Suspender prescricao
 Local bFS_SusIte := {||FS_TratFun("4", nOpc)} // Suspender Item
 Local bFS_HorEnf := {||FS_HorEnf(M->GCY_REGATE, cSeqPre)} // Suspender horarios
 Local bFS_PrePad := {||FS_TratFun("5", nOpc, cSeqPre)} // Prescricao Padrao
 Local bFS_Imprim	:= {||FS_TratFun("6", nOpc,, cTpNasc )} // Impressao prescricao
 Local bFS_EncPre	:= {||FS_TratFun("8", nOpc)} // Encerrar Prescricao  
 Local bFS_GerLeg := {||FS_GerLeg()}
 Local bFS_CerDig  := {||FS_TratFun("9", nOpc)} // Encerrar Prescricao  
 Local bKeyF4, bKeyF5
 Local aButtons := {}  
 Local nLin := 0  
 Local cOrderBy := ""
                 
 Private __aItPresc := {{"oGHX:aCols[oGHX:nAt, nGhxTpItmp]",     "03"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxStareg]",     "04"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxCdMedi]",     "01"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxDsItem]",     "02"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxCdItmp]", "10, 02"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxAprese]",     "05"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxApresD]", "10, 06"},;  
                        {"oGHX:aCols[oGHX:nAt, nGhxCodVia]", "10, 04"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxDesvia]", "10, 05"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxCdItpo]", "11, 02"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxCdFrqa]", "11, 03"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxDsFrqa]", "11, 04"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxCdItuc]", "12, 02"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxCdunic]", "12, 03"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxDunico]", "12, 04"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxDispar]",     "06"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxIdRegi]",     "07"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxObsreg]",     "08"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxObserv]",     "09"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxQtdMed]",     "14"}}

						If HS_EXISDIC({{"C", "GHX_JUSTIF"}},.F.) 
							AADD(__aItPresc,{"oGHX:aCols[oGHX:nAt, nGhxJustif]",     "15"})
						EndIf
  

 Private __aItCompo := {{"oGHX:aCols[oGHX:nAt, nGhxTpItmp]", "13, 08"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxStareg]",     "04"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxCdMedi]", "13, 02"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxDsItem]", "13, 03"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxAprese]", "13, 09"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxQtdMed]", "13, 04"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxCdunic]", "13, 05"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxDunico]", "13, 06"}}
                        
 Private __aItDieta := {{"oGHX:aCols[oGHX:nAt, nGhxTpItmp]",     "03"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxStareg]",     "04"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxCdMedi]",     "01"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxDsItem]",     "02"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxVolume]",     "05"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxCodVia]",     "06"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxDesvia]",     "07"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxVelInf]",     "08"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxCdMinf]",     "09"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxDsMinf]",     "10"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxCdFrqa]",     "11"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxDsFrqa]",     "12"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxObsreg]",     "13"}}
                         
                        
 Private __aItCuida := {{"oGHX:aCols[oGHX:nAt, nGhxTpItmp]",     "03"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxStareg]",     "04"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxCdMedi]",     "01"},; 
                        {"oGHX:aCols[oGHX:nAt, nGhxDsItem]",     "02"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxCdFrqa]",     "05"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxDsFrqa]",     "06"},;
                        {"oGHX:aCols[oGHX:nAt, nGhxObsreg]",     "07"}}
                                                                    

 Private aLegGhv  := {{"TMPGHV->GHV_STATUS == '0'", "BR_VERMELHO"   }, ; //Suspensa
                     {"TMPGHV->GHV_STATUS == '1'", "BR_VERDE" }, ; //Ativa
                     {"TMPGHV->GHV_STATUS == '2'", "BR_AZUL"},; //Administrada
                     {"TMPGHV->GHV_STATUS == '3' .And. TMPGHV->GHV_DATPRE < dDataBase", "BR_PINK"},; //Atrasada
                     {"TMPGHV->GHV_STATUS == '3' .And. TMPGHV->GHV_DATPRE >= dDataBase", "BR_CINZA"}} //Encerrada 
 
 Private aLegGhx  := {{"TMPGHX->GHX_STATUS == '0'", "BR_VERMELHO"   }, ; //Suspensa
                     {"TMPGHX->GHX_STATUS == '1'", "BR_VERDE" }} //Ativa
                    
 Private nOpcAbq := nOpc                                                                 
 Private oEncGCY, oGHV, oGHX, oDlgABQ
 Private aHGHV := {}, aCGHV := {}, nUGHV := 0
 Private aHGHX := {}, aCGHX := {}, nUGHX := 0   
 Private cGcyAtendi := ""
 
 Private aTela := {}, aGets := {}, aCDatAtu := {} 
 Private nGhvDatPre := 0, nGhvStareg := 0, nGhvSeqPre := 0, nGhvHorCri := 0, nGhvMotivo := 0, nGhvDesMot := 0
 Private nGhvCodCrm := 0, nGhvNomMed := 0, nGhvUsuSus := 0, nGhvDatSus := 0, nGhvHorSus := 0, nGhvImpVia := 0, nGhxJustif := 0
 Private nGhxAprese := 0, nGhxCdItmp := 0, nGhxItemBr := 0, nGhxTpItmp := 0, nGhxStareg := 0, nGhxMotivo := 0, nGhxDesMot := 0
 Private nGhxCdMedi := 0, nGhxDsItem := 0, nGhxApresD := 0, nGhxCdItpo := 0, nGhxCdFrqa := 0, nGhxDsFrqa := 0, nGhxCdItuc := 0
 Private nGhxCdunic := 0, nGhxDunico := 0, nGhxDispar := 0, nGhxIdRegi := 0, nGhxObsreg := 0, nGhxObserv := 0, nGhxUsuSus := 0
 Private nGhxDatSus := 0, nGhxHorSus := 0, nGhxSeqIte := 0, nGhxVolume := 0, nGhxCodVia := 0, nGhxDesvia := 0, nGhxCdMinf := 0
 Private nGhxDsMinf := 0, nGhxVelInf := 0, nGhxQtdMed := 0 
 Private aTelaGCY   := {}, aTelaGB2 := {}   
 Private lExDicJust := HS_EXISDIC({{"C", "GHX_JUSTIF"}},.F.) 


 Default cTpNasc    := ""

 Aadd(aButtons	,{'EDIT'    ,  {||Eval(bFS_Inclui)}, STR0006, STR0007})  //"Incluir Prescri็ใo"###"Inc.Pres."
 Aadd(aButtons	,{'NOTE'    ,  {||Eval(bFS_IncPre)}, STR0050, STR0051}) // "Incluir item da prescri็ใo"##"Inc. Item"  
 Aadd(aButtons	,{'S4WB005N',  {||Eval(bFS_Copiar)}, STR0008, STR0009}) //"Copiar Prescri็ใo"###"Cop.Pres."
 Aadd(aButtons	,{'EXCLUIR' ,  {||Eval(bFS_Suspen)}, STR0010, STR0011}) //"Suspender Prescri็ใo"###"Sus.Pres."
 Aadd(aButtons	,{'EXCLUIR' ,  {||Eval(bFS_SusIte)}, STR0012, STR0013}) //"Suspender Item"###"Sus.Item"
 Aadd(aButtons	,{'CLOCK01' ,  {||Eval(bFS_HorEnf)}, STR0060, STR0061}) //"Suspender horแrio"##"Sus.Hor."
 Aadd(aButtons	,{'NOTE'    ,  {||Eval(bFS_PrePad)}, STR0014, STR0015}) //"Prescri็ใo Padrใo"###"Pr. Padr."
 Aadd(aButtons ,{'OBJETIVO',  {||Eval(bFS_EncPre)}, STR0053, STR0054}) // "Encerrar Prescri็ใo"##"Enc. Pres."
 Aadd(aButtons	,{'S4WB010N',  {||Eval(bFS_Imprim)}, STR0016, STR0017}) //"Imprimir Prescri็ใo"###"Imp.Pres."
 Aadd(aButtons ,{'DBG07'   ,  {||Eval(bFS_GerLeg)}, STR0018, STR0019  }) //"Mostra Legenda"###"Legenda"
 If GetNewPar("MV_HSPCERD","0") == "1"
 	Aadd(aButtons	,{'NOTE'    ,  {||Eval(bFS_CerDig)}, STR0077, STR0078}) //"Certificado Digital"###"Cert.Dig."
 EndIf
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ P.E. utilizado para adicionar novas opcoes ao menu           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock("HM30BTADD")
	aBtAdd := ExecBlock("HM30BTADD",.F.,.F.,{aButtons})
	If ValType(aBtAdd) == "A"
		AEval(aBtAdd,{|x| AAdd(aButtons,x)})
	EndIf
EndIf
 
 bKeyf4 :=	SetKey( VK_F4, { || Eval(bFS_Suspen)} )
 bKeyf5 :=	SetKey( VK_F5, { || Eval(bFS_SusIte)} )

 RegToMemory("GCY",.F.)   
 cGcyAtendi := "0"
 HS_CposGcy(2, @aCposObr, @aCposGcy, @aCposAlt)

 If !Empty(cTpNasc)
  DbSelectArea("GB2")
  DbSetOrder(1) // GBI_FILIAL + GBI_PRODUT
  If !(DbSeek(xFilial("GB2") + M->GCY_REGATE + cTpNasc))
   cTpNasc := ""
  Else
   nRegGB2 := GB2->(recno())
   RegToMemory("GB2",.F.)
  Endif
 EndIf 

 cSeqPre := FS_MAXGHV(M->GCY_REGATE)
  cOrderBy :="GHV_SEQPRE DESC"

 HS_BDados("GHV", @aHGHV  , @aCGHV , @nUGHV , 1   ,        , "GHV->GHV_REGATE == '" + M->GCY_REGATE + "' AND GHV->GHV_RESERV == '" + cTpNasc + "' ",        ,"GHV_STATUS",        ,         ,        ,        ,        ,        ,        ,aLegGhv,        ,         ,           ,         ,         ,      ,          , cOrderBy)
 
 nGhvDatpre := aScan(aHGHV, {|aVet| aVet[2] == "GHV_DATPRE"})
 nGhvStareg := aScan(aHGHV, {|aVet| aVet[2] == "GHV_STATUS"}) 
 nGhvSeqpre := aScan(aHGHV, {|aVet| aVet[2] == "GHV_SEQPRE"})
 nGhvHorCri := aScan(aHGHV, {|aVet| aVet[2] == "GHV_HORCRI"})
 nGhvMotivo := aScan(aHGHV, {|aVet| aVet[2] == "GHV_MOTIVO"})
 nGhvDesMot := aScan(aHGHV, {|aVet| aVet[2] == "GHV_DESMOT"})
 nGhvCodCrm := aScan(aHGHV, {|aVet| aVet[2] == "GHV_CODCRM"})
 nGhvNomMed := aScan(aHGHV, {|aVet| aVet[2] == "GHV_NOMMED"})
 nGhvUsuSus := aScan(aHGHV, {|aVet| aVet[2] == "GHV_USUSUS"})
 nGhvDatSus := aScan(aHGHV, {|aVet| aVet[2] == "GHV_DATSUS"})
 nGhvHorSus := aScan(aHGHV, {|aVet| aVet[2] == "GHV_HORSUS"})
 nGhvImpVia := aScan(aHGHV, {|aVet| aVet[2] == "GHV_IMPVIA"})
                                                             
 If Empty(aCGHV[1, nGhvSeqpre])
  aCGHV[1, nGhvSeqpre] := Soma1(cSeqPre, Len(aCGHV[1, nGhvSeqpre]))
 EndIf 
  
 HS_BDados("GHX", @aHGHX, @aCGHX, @nUGHX, 1,, "GHX->GHX_SEQPRE == '"+ aCGHV[1 ,nGhvSeqPre] + "' AND GHX->GHX_REGATE == '" + M->GCY_REGATE + "' AND GHX_TPITMP <> '5' AND GHX_TPUSUA <> '2'",,"GHX_STATUS",,,,,,,,aLegGhx,,.T.,,,,,,"GHX_SEQITE")   
 
 
 nGhxItemBr := aScan(aHGHX, {|aVet| aVet[2] == "GHX_ITEMBR"})
 nGhxTpItmp := aScan(aHGHX, {|aVet| aVet[2] == "GHX_TPITMP"})
 nGhxAprese := aScan(aHGHX, {|aVet| aVet[2] == "GHX_APRESE"})
 nGhxCdItmp := aScan(aHGHX, {|aVet| aVet[2] == "GHX_CDITMP"})  
 nGhxStareg := aScan(aHGHX, {|aVet| aVet[2] == "GHX_STATUS"}) 
 nGhxMotivo := aScan(aHGHX, {|aVet| aVet[2] == "GHX_MOTIVO"})
 nGhxDesMot := aScan(aHGHX, {|aVet| aVet[2] == "GHX_DESMOT"})     
 nGhxCdMedi := aScan(aHGHX, {|aVet| aVet[2] == "GHX_CDMEDI"})
 nGhxDsItem := aScan(aHGHX, {|aVet| aVet[2] == "GHX_DSITEM"})
 nGhxApresD := aScan(aHGHX, {|aVet| aVet[2] == "GHX_APRESD"})
 nGhxCdItpo := aScan(aHGHX, {|aVet| aVet[2] == "GHX_CDITPO"})  
 nGhxCdFrqa := aScan(aHGHX, {|aVet| aVet[2] == "GHX_CDFRQA"}) 
 nGhxDsFrqa := aScan(aHGHX, {|aVet| aVet[2] == "GHX_DSFRQA"})
 nGhxCdItuc := aScan(aHGHX, {|aVet| aVet[2] == "GHX_CDITUC"})
 nGhxCdunic := aScan(aHGHX, {|aVet| aVet[2] == "GHX_CDUNIC"})
 nGhxDunico := aScan(aHGHX, {|aVet| aVet[2] == "GHX_DUNICO"})
 nGhxDispar := aScan(aHGHX, {|aVet| aVet[2] == "GHX_DISPAR"})  
 nGhxIdRegi := aScan(aHGHX, {|aVet| aVet[2] == "GHX_IDREGI"}) 
 nGhxObsreg := aScan(aHGHX, {|aVet| aVet[2] == "GHX_OBSREG"})
 nGhxObserv := aScan(aHGHX, {|aVet| aVet[2] == "GHX_OBSERV"}) 
 nGhxUsuSus := aScan(aHGHX, {|aVet| aVet[2] == "GHX_USUSUS"})
 nGhxDatSus := aScan(aHGHX, {|aVet| aVet[2] == "GHX_DATSUS"})
 nGhxHorSus := aScan(aHGHX, {|aVet| aVet[2] == "GHX_HORSUS"})
 nGhxSeqIte := aScan(aHGHX, {|aVet| aVet[2] == "GHX_SEQITE"})
 nGhxVolume := aScan(aHGHX, {|aVet| aVet[2] == "GHX_VOLUME"})
 nGhxCodVia := aScan(aHGHX, {|aVet| aVet[2] == "GHX_CODVIA"})
 nGhxDesvia := aScan(aHGHX, {|aVet| aVet[2] == "GHX_DESVIA"})
 nGhxCdMinf := aScan(aHGHX, {|aVet| aVet[2] == "GHX_CDMINF"})
 nGhxDsMinf := aScan(aHGHX, {|aVet| aVet[2] == "GHX_DSMINF"})
 nGhxVelInf := aScan(aHGHX, {|aVet| aVet[2] == "GHX_VELINF"}) 
 nGhxQtdMed := aScan(aHGHX, {|aVet| aVet[2] == "GHX_QTDMED"}) 
 If lExDicJust 
 	nGhxJustif := aScan(aHGHX, {|aVet| aVet[2] == "GHX_JUSTIF"})  
 EndIf
   
 If Empty(aCGHX[1, nGhxItemBr])
  aCGHX[1, nGhxItemBr] := Soma1(aCGHX[1, nGhxItemBr], Len(aCGHX[1, nGhxItemBr]))
 EndIf 
 
If nGhxJustif > 0 .AND. lExDicJust
	aHGHX[nGhxjustif,8] := "C"
EndIf
  
 aSize := MsAdvSize()
 
 aObjects := {{100, 050, .T., .T.}, ;
             {100, 050, .T., .T.}}
 
 aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)                     
  
 aObjects := {{065, 100, .T., .T., .T.}, ;
              {035, 100, .T., .T.}}

 aInfo := {aPObjs[1, 2], aPObjs[1, 1], aPObjs[1, 4], aPObjs[1, 3], 0, 0}
 aPEnc := MsObjSize(aInfo, aObjects, .T., .T.)
 
 nOpcA := 0
 DEFINE MSDIALOG oDlgAbq TITLE STR0020 From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel    //"Cadastro Prescri็ใo Medica"
 
 IF !Empty(cTpNasc)
  @ aPObjs[1, 1], aPObjs[1, 2] FOLDER oFolder SIZE aPObjs[1, 3], aPObjs[1, 4] Pixel Of oDlgAbq Prompts "RN", STR0004 //"Paciente"
 Else 
  @ aPObjs[1, 1], aPObjs[1, 2] FOLDER oFolder SIZE aPObjs[1, 3], aPObjs[1, 4] Pixel Of oDlgAbq Prompts  STR0004 //"Paciente"
 Endif
 oFolder:Align:= CONTROL_ALIGN_ALLCLIENT
  
  If !Empty(cTpNasc)
//   oEncGB2 := MsMGet():New("GB2", nRegGB2, 2,,,,, aPEnc[1],, 2,,,,oFolder:aDialogs[1],,,, "aTelaGB2",,.T.)
   oEncGB2 := MsMGet():New("GB2", nRegGB2, 2,,,,, {015, 001, 070, 315},, 2,,,,oFolder:aDialogs[1],,,,,,.T.)
   oEncGB2 :oBox:Align := CONTROL_ALIGN_ALLCLIENT	
  EndIf
  
//  oEncGCY := MsMGet():New("GCY", nReg, 2,,,,aCposGCY, aPEnc[1],, 2,,,,IIF(!Empty(cTpNasc), oFolder:aDialogs[2], oFolder:aDialogs[1]),,,, "aTelaGCY",,.T.)
  oEncGCY := MsMGet():New("GCY", nReg, 2,,,,aCposGCY, {015, 001, 070, 315},, 2,,,,IIF(!Empty(cTpNasc), oFolder:aDialogs[2], oFolder:aDialogs[1]),,,,,,.T.)
  oEncGCY :oBox:Align := CONTROL_ALIGN_ALLCLIENT
  
//  oGHV := MsNewGetDados():New(aPEnc[2, 1], aPEnc[2, 2], aPEnc[2, 3], aPEnc[2, 4], nOpcGhv,,,"+GHV_SEQPRE",,, 999999,,,,, aHGHV, aCGHV)
  oGHV := MsNewGetDados():New(aPEnc[2, 1], aPEnc[2, 2], aPEnc[2, 3], aPEnc[2, 4],GD_UPDATE,,,"+GHV_SEQPRE",{"GHV_HORCRI"},, 999999,,,,, aHGHV, aCGHV)
  oGHV:lEditLine := .F.
  oGHV:oBrowse:bchange:= {|| FS_ATUGHX(oGHV:aCols[oGHV:oBrowse:nAt, nGhvSeqPre], aCDatAtu)}
  oGHV:oBrowse:Align  := CONTROL_ALIGN_RIGHT


  If lExDicJust
  	FS_ACPMEMO(nGhxJustif, @aCGHX,M->GCY_REGATE, nGhxItemBr )
  EndIf
  oGHX := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nOpcGhx,"HS_DuplAC(oGHX:oBrowse:nAt, oGHX:aCols, { nGhxTpItmp, nGhxAprese, nGhxCdItmp})",,"+GHX_ITEMBR",,, 99999,,,,, aHGHX, aCGHX)
  oGHX:oBrowse:bLostFocus := {|| FS_MNTCOL(@aCDatAtu)} 
  oGHX:oBrowse:bDelete    := {|| IIF(oGHV:aCols[oGHV:oBrowse:nAt, nGhvStaReg] == "BR_VERDE" .And. FS_VLDDEL(), oGhx:DELLINE(), .F.) }
  oGHX:oBrowse:Align  := CONTROL_ALIGN_BOTTOM 
  If lExDicJust
  	oGHX:oBrowse:BlDblClick := {|| IIf(oGHX:oBrowse:ColPos == nGhxJustif,FS_EMemo("Justificativa",M->GCY_REGATE,oGHV:aCols[oGHV:oBrowse:nAt, nGhvDatpre],oGHV:aCols[oGHV:oBrowse:nAt, nGhvSeqPre], oGHX:aCols[oGHX:oBrowse:nAt, nGhxItemBr]),)}
  EndIf
 
  oDlgAbq:bStart := { || FS_ATUSTA()} 
  
 ACTIVATE MSDIALOG oDlgAbq ON INIT EnchoiceBar(oDlgAbq, {|| nOpcA := 1, IIf(oGHX:TudoOk() .And.  FS_MNTCOL(@aCDatAtu) .And. FS_VLDOK(), oDlgAbq:End(), nOpcA := 0)}, ;
                                                        {|| nOpcA := 0, oDlgAbq:End()},,aButtons)   
                                                  
 If nOpcA == 1
  If aRotina[nOpcAbq, 4] == 4
   Inclui := .F.
   Altera := .T.
  Endif 
  
  Begin Transaction 
   FS_GRVAbq(cTpNasc)
  End Transaction
  
  While __lSx8
   ConfirmSx8()
  End  
 Else
  While __lSx8
   RollBackSxe()
  End            
 Endif
               
Return()


Static Function FS_ACPMEMO(nPosHead, aCols , cRegAte , nPosItemBr)
Local nFor 	:= 0
Local cMemo := ""   
Local aArea   := GetArea()                         

If HS_EXISDIC({{"C", "GHX_JUSTIF"}},.F.)  
	If Len(aCols) > 0
		For nFor := 1 to Len(aCols)
			If !Empty(aCols[nFor,nPosItemBr])
				DbSelectArea("GHX")
				DbSetOrder(1)
				If DbSeek(xFilial("GHX") + aCols[nFor,nPosItemBr] + cRegAte + oGHV:aCols[oGHV:oBrowse:nAt, nGhvSeqPre] + DTOS(oGHV:aCols[oGHV:oBrowse:nAt, nGhvDatpre]))
					cMemo := E_MSMM(GHX->GHX_JUSTIF)
				EndIf                        
				If !Empty(cMemo)
					aCols[nFor,nPosHead] := cMemo
				Else				
					aCols[nFor,nPosHead] := ""
				EndIf
				//GHX->(DbCloseArea())
			Else                              
				aCols[nFor,nPosHead] := ""
			EndIf
		Next nFor
	EndIf                            
EndIf
RestArea(aArea)
Return()

Static Function FS_EMemo(cLabel,cRegAte,dDatPre,cSeqPre, cItemBr)
Local oDlgM
Local cSql := ""
Local cTexto := ""
Local lExDicJust := HS_EXISDIC({{"C", "GHX_JUSTIF"}},.F.)

cLabel := IIf(cLabel == Nil,            "", cLabel)

If !lExDicJust	
	Return(Nil)
EndIf

DbSelectArea("GHX")
DbSetOrder(1)
If DbSeek(xFilial("GHX") + cItemBr + cRegAte + cSeqPre + DTOS(dDatPre))
	cTexto := E_MSMM(GHX->GHX_JUSTIF)
EndIf

If Empty(Alltrim(cTexto))  
	If ValType(oGHX:aCols[oGHX:oBrowse:nAt, nGhxJustif]) == "C" .AND. !Empty(oGHX:aCols[oGHX:oBrowse:nAt, nGhxJustif])  .AND. oGHX:aCols[oGHX:oBrowse:nAt, nGhxJustif] <> "Memo"
		cTexto := oGHX:aCols[oGHX:oBrowse:nAt, nGhxJustif]
	Else
		Return(Nil)
	EndIf
EndIf 

If Alltrim(cTexto) == "Memo"
	Return(Nil)
EndIf

DEFINE MSDIALOG oDlgM FROM	62,100 TO 280,510 TITLE STR0071 PIXEL

@ 015, 004 TO 085, 200 Label cLabel OF oDlgM PIXEL
//@ 025, 010 GET oTexto VAR cTexto MEMO SIZE 178.64, 051 OF oDlgM PIXEL   
@ 025, 010 GET oTexto VAR cTexto MEMO READONLY SIZE 178.64, 051 OF oDlgM PIXEL  

DEFINE SBUTTON FROM 90,170 TYPE 1 ACTION (oDlgM:End()) ENABLE OF oDlgM

ACTIVATE MSDIALOG oDlgM CENTERED //VALID IIf(Empty(Alltrim(cTexto)),.F.,.T.)                                     


Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FS_GRVABQณ Autor ณ Mario Arizono         ณ Data ณ14/05/2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ                        	
ฑฑณDescrio ณ Funcao para gravacao das Prescricoes Medicas               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GRVABQ(cTpNasc)
Local nForGHV := 0, nCabAcol := 0, nIteAcol := 0, nForKit := 0
Local lAchouGHV := .F., lAchouGHX := .F.
Local cStatus   := "", cStaGhx := "", cSeqPri := "", cSeqItem := ""
Local aRetkit   := {}

If aRotina[nOpcAbq, 4] == 2
	Return()
Else
	For nForGHV := 1 to len(oGhv:aCols)
		DbSelectArea("GHV")
		DbSetOrder(1)
		lAchouGHV := DbSeek(xFilial("GHV") + M->GCY_REGATE + oGHV:aCols[nForGHV, nGhvSeqPre] + DTOS(oGHV:aCols[nForGHV, nGhvDatPre]))
		cStatus := Str(aScan(aLegGhv, {| aVet | aVet[2] == oGHV:aCols[nForGhv, nGhvStaReg]}) - 1, 1)
		cStatus := IIf(cStatus $ '3|4', "3", cStatus)
		If !Empty(oGHV:aCols[nForGHV, nGhvDatPre])
			RecLock("GHV", !lAchouGHV)
			HS_GRVCPO("GHV", oGhv:aCols, oGhv:aHeader, nForGHV)
			GHV->GHV_FILIAL := xFilial("GHV")
			GHV->GHV_REGATE := M->GCY_REGATE
			GHV->GHV_STATUS := cStatus
			GHV->GHV_CODUSU := cUserName
			GHV->GHV_HORCRI := oGhv:aCols[nForGHV, nGhvHorCri]
			If !Empty(cTpNasc)
				GHV->GHV_RESERV := cTpNasc
			Endif
			MsUnlock()
		Endif
	Next nForGHV
	If !Empty(aCDatAtu)
		For nCabAcol := 1 to len(aCDatAtu)
			For nIteACol := 1 to len(aCDatAtu[nCabAcol,2])
				DbSelectArea("GHX")
				DbSetOrder(1)
				lAchouGHX := DbSeek(xFilial("GHX") + aCDatAtu[nCabAcol][2][nIteACol][nGhxItemBr] + M->GCY_REGATE +  aCDatAtu[nCabAcol][1])
				cStaGhx := Str(aScan(aLegGhx, {| aVet | aVet[2] == aCDatAtu[nCabAcol][2][nIteACol][nGhxStaReg]}) - 1, 1)
				If  aCDatAtu[nCabAcol][2][nIteACol][len(aCDatAtu[nCabAcol][2][nIteACol])] .And. lAchouGHX // exclusao
					RecLock("GHX", .F., .T.)
					Dbdelete()
					MsUnlock()
					WriteSx2("GHX")
				ElseIf !( aCDatAtu[nCabAcol][2][nIteACol][len(aCDatAtu[nCabAcol][2][nIteACol])] ) .And. !Empty(aCDatAtu[nCabAcol][2][nIteACol][nGhxItemBr])
					RecLock("GHX", !lAchouGHX)
					GHX->GHX_FILIAL  := xFilial("GHX")
					GHX->GHX_ITEMBR  := aCDatAtu[nCabAcol][2][nIteACol][nGhxItemBr]
					GHX->GHX_TPITMP  := aCDatAtu[nCabAcol][2][nIteACol][nGhxTpItmp]
					GHX->GHX_APRESE  := aCDatAtu[nCabAcol][2][nIteACol][nGhxAprese]
					GHX->GHX_CDITMP  := aCDatAtu[nCabAcol][2][nIteACol][nGhxCdItmp]
					GHX->GHX_CDMEDI  := aCDatAtu[nCabAcol][2][nIteACol][nGhxCdMedi]
					GHX->GHX_APRESD  := aCDatAtu[nCabAcol][2][nIteACol][nGhxApresD]
					GHX->GHX_CDITPO  := aCDatAtu[nCabAcol][2][nIteACol][nGhxCdItpo]
					GHX->GHX_CDITUC  := aCDatAtu[nCabAcol][2][nIteACol][nGhxCdItuc]
					GHX->GHX_DISPAR  := aCDatAtu[nCabAcol][2][nIteACol][nGhxDispar]
					GHX->GHX_IDREGI  := aCDatAtu[nCabAcol][2][nIteACol][nGhxIdRegi]
					GHX->GHX_OBSREG  := aCDatAtu[nCabAcol][2][nIteACol][nGhxObsReg]
					GHX->GHX_OBSERV  := aCDatAtu[nCabAcol][2][nIteACol][nGhxObserv]
					GHX->GHX_CDFRQA  := aCDatAtu[nCabAcol][2][nIteACol][nGhxCdFrqa]
					GHX->GHX_CDUNIC  := aCDatAtu[nCabAcol][2][nIteACol][nGhxCdUnic]
					GHX->GHX_DATPRE  := dDatabase
					GHX->GHX_REGATE  := M->GCY_REGATE
					GHX->GHX_STATUS  := cStaGhx
					GHX->GHX_SEQPRE  := aCDatAtu[nCabAcol][1]
					GHX->GHX_MOTIVO  := aCDatAtu[nCabAcol][2][nIteACol][nGhxMotivo]
					GHX->GHX_USUSUS  := aCDatAtu[nCabAcol][2][nIteACol][nGhxUsuSus]
					GHX->GHX_DATSUS  := aCDatAtu[nCabAcol][2][nIteACol][nGhxDatSus]
					GHX->GHX_HORSUS  := aCDatAtu[nCabAcol][2][nIteACol][nGhxHorSus]
					GHX->GHX_SEQITE  := aCDatAtu[nCabAcol][2][nIteACol][nGhxSeqIte]
					GHX->GHX_VOLUME  := aCDatAtu[nCabAcol][2][nIteACol][nGhxVolume]
					GHX->GHX_CODVIA  := aCDatAtu[nCabAcol][2][nIteACol][nGhxCodVia]
					GHX->GHX_CDMINF  := aCDatAtu[nCabAcol][2][nIteACol][nGhxCdMinf]
					GHX->GHX_VELINF  := aCDatAtu[nCabAcol][2][nIteACol][nGhxVelInf]
					GHX->GHX_QTDMED  := aCDatAtu[nCabAcol][2][nIteACol][nGhxQtdMed]
					If Empty(GHX->GHX_TPUSUA)
						GHX->GHX_TPUSUA := "1"
					Endif
					
					If cStaGhx == "0"
						GHX->GHX_STAENF := "3"
					Endif
					
					GHX->GHX_SEQPRI  := IIf (aCDatAtu[nCabAcol][2][nIteACol][nGhxTpItmp] == "4", cSeqPri, GHX->GHX_ITEMBR)
					
					MsUnlock()
					If  HS_EXISDIC({{"C", "GHX_JUSTIF"}},.F.)
						If ValType(aCDatAtu[nCabAcol][2][nIteACol][nGhxJustif]) == "C"
							MSMM(, TamSx3("GHX_JUSTIF")[1],, aCDatAtu[nCabAcol][2][nIteACol][nGhxJustif], 1,,, "GHX","GHX_JUSTIF" )
						EndIf
					EndIf
					
					If aCDatAtu[nCabAcol][2][nIteACol][nGhxTpItmp] == "2" .And. !lAchouGhx
						DbSelectArea("GDY")
						Reclock("GDY", .T.)
						
						GDY->GDY_FILIAL := xFilial("GDY")
						GDY->GDY_REGATE := M->GCY_REGATE
						GDY->GDY_SEQPRE := aCDatAtu[nCabAcol][1]
						GDY->GDY_CODDIE := aCDatAtu[nCabAcol][2][nIteACol][nGhxCdMedi]
						GDY->GDY_DATDIE := dDatabase
						GDY->GDY_HORDIE := Time()
						GDY->GDY_ATIVO  := "1"
						GDY->GDY_OBSERV := aCDatAtu[nCabAcol][2][nIteACol][nGhxObsReg]
						GDY->GDY_VOLUME := aCDatAtu[nCabAcol][2][nIteACol][nGhxVolume]
						GDY->GDY_CDFRQA := aCDatAtu[nCabAcol][2][nIteACol][nGhxCdFrqa]
						GDY->GDY_CODVIA := aCDatAtu[nCabAcol][2][nIteACol][nGhxCodVia]
						GDY->GDY_VELINF := aCDatAtu[nCabAcol][2][nIteACol][nGhxVelInf]
						GDY->GDY_CDMINF := aCDatAtu[nCabAcol][2][nIteACol][nGhxCdMinf]
						
						MsUnlock()
						
					Endif
					
					If aCDatAtu[nCabAcol][2][nIteACol][nGhxTpItmp] == "1" .And. !Empty(aCDatAtu[nCabAcol][2][nIteACol][nGhxSeqIte]) .And. ;
						(HS_CountTB("GHX", "GHX_SEQPRE = '" + aCDatAtu[nCabAcol][1] + "' AND GHX_SEQPRI = '" + aCDatAtu[nCabAcol][2][nIteACol][nGhxItemBr] + ;
						"' AND GHX_TPITMP = '5' ")  == 0)
						
						aRetKit :=  FS_RETKIT(aCDatAtu[nCabAcol][2][nIteACol][nGhxCdMedi] ,aCDatAtu[nCabAcol][2][nIteACol][nGhxCodVia])
						
						If !Empty(aRetKit)
							For nForKit := 1 to len(aRetKit)
								RecLock("GHX", .T.)
								If Empty(cSeqItem)
									cSeqItem := Soma1(aCDatAtu[nCabAcol][2][len(aCDatAtu[nCabAcol,2])][nGhxItemBr], len(GHX->GHX_ITEMBR))
								Endif
								GHX->GHX_FILIAL  := xFilial("GHX")
								GHX->GHX_DATPRE  := dDatabase
								GHX->GHX_ITEMBR  := cSeqItem
								GHX->GHX_TPITMP  := "5"
								GHX->GHX_QTDMED  := aRetKit[nForKit, 3]
								GHX->GHX_CDMEDI  := aRetKit[nForKit, 2]
								GHX->GHX_REGATE  := M->GCY_REGATE
								GHX->GHX_STATUS  := cStaGhx
								GHX->GHX_CDUNIC  := HS_IniPadr("SB1", 1, aRetKit[nForKit, 2], "B1_UM")
								GHX->GHX_SEQPRE  := aCDatAtu[nCabAcol][1]
								GHX->GHX_SEQITE  := aCDatAtu[nCabAcol][2][nIteACol][nGhxSeqIte]
								GHX->GHX_SEQPRI  := aCDatAtu[nCabAcol][2][nIteACol][nGhxItemBr]
								GHX->GHX_CODKIT  := aRetKit[nForKit, 1]
								If Empty(GHX->GHX_TPUSUA)
									GHX->GHX_TPUSUA := "1"
								Endif
								MsUnlock()
								
								cSeqItem := Soma1(cSeqItem, len(GHX->GHX_ITEMBR))
							Next
						Endif
					Endif
					
				Endif
				If aCDatAtu[nCabAcol][2][nIteACol][nGhxTpItmp] == "1"
					cSeqPri := aCDatAtu[nCabAcol][2][nIteACol][nGhxItemBr]
				Endif
			Next nIteAcol
		Next nCabAcol
	Endif
Endif

Return()
                   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFS_FilAbq ณ Autor ณ Mario Arizono         ณ Data ณ09/05/07ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Rotina para filtrar dados do browse principal.           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/


Static Function FS_FilAbq(cPerg, lSetFilter)
 Local lRet       := .F.
 Local oObjMBrw   := GetObjBrow()
 Local cCodLocIni := "", cCodLocFim := "", cReggerIni := "", cReggerFim := ""
 Local dDatAteIni := CTOD("  /  /  "), dDatAteFim := CTOD("  /  /  ")
   
 
 If (lRet := Pergunte(cPerg))
  cCodLocIni := mv_par01
  cCodLocFim := mv_par02  
  cReggerIni := mv_par03
  cReggerFim := mv_par04
  dDatAteIni := mv_par05
  dDatAteFim := mv_par06

  cFilAbq := "GCY_FILIAL = '" + xFilial("GCY") + "'"  
  cFilAbq += " AND GCY_TPALTA = '" + Space(len(GCY->GCY_TPALTA)) + "' AND GCY_TPALTA <> '99'" 
  cFilAbq += " AND GCY_CODLOC BETWEEN '" + cCodLocIni + "' AND '" + cCodLocFim + "'"
  cFilAbq += " AND GCY_REGGER BETWEEN '" + cReggerIni + "' AND '" + cReggerFim + "'"
  cFilAbq += " AND GCY_DATATE BETWEEN '" + DTOS(dDatAteIni) + "' AND '" + DTOS(dDatAteFim) + "'"
    
  If lSetFilter
   SetMBTopFilter("GCY", cFilAbq)
   oObjMBrw:GoTop()
   oObjMBrw:Refresh()
  EndIf
 EndIf
 DbSelectArea("GCY")
 
    
Return(lRet)

       

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TRATFUN บ Autor ณ MARIO ARIZONO      บ Data ณ  11/05/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para tratamento dos botoes da enchoice bar           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Static Function FS_TratFun(cOpcBot, nOpc, cSeqPre, cTpNasc, lCertDig)         
 Local nGhv := 0, nPosImp := 0, nPosPre := 0, nPosTip := 0
 Local cNomPac := "", cCodLoc := "", cQuaint := "", cLeiInt := "", cIdade := ""
 Local lRet := .T. 
 Local cSeqAnt := "", cImpVia := "", cStatus := ""
 Local aArea   := GetArea()
 Local aMntPad := {}, aMntImp := {}, aTpItem := {"2", "1/4", "3"}
 Local cSoma   := "000"
 
 Default cSeqPre := ""
 Default cTpNasc := ""
 Default lCertDig := .F.
 
 If  cOpcBot <> "6" .And. !aCodUsr[3]
  HS_MsgInf(STR0055, STR0008, STR0056) //"Usuแrio nใo tem permissใo para acessar esta op็ใo. Verifique o campo 'Tipo de profissional' no cadastro de profissional."##"Valida็ใo usuแrio da prescri็ใo"  
  Return(Nil)   
 Endif
  
If nOpc == 1
	If cOpcBot $ "1/5" //Incluir prescricao
		If GCY->GCY_DATATE > dDataBase
			HS_MSGINF(STR0072,STR0022, STR0030)//"Nใo ้ possํvel criar uma prescri็ใo para uma data anterior a data do atendimento!"
			Return(Nil)
		EndIf
		If Empty(oGHV:aCols[1, nGhvDatPre])
			If cOpcBot ==  "5"
				aMntPad := FS_MNTPAD()
			Endif
			If !Empty(aMntPad) .Or. cOpcBot == "1"
				FS_ATUGHV(1)    
				FS_AtriLeg(oGHV:aCols,1, nGhvStaReg, "BR_VERDE")
				If cOpcBot == "5"
					FS_PREPAD(aMntPad)
				Endif
			Endif
		Else
			For nGhv := 1 to len(oGHV:aCols)
				If oGHV:aCols[nGhv, nGhvDatPre] == dDatabase .And. oGHV:aCols[nGhv, nGhvStaReg] == "BR_VERDE"
					Hs_MsgInf(STR0029, STR0022, STR0030) //"Jแ existe prescri็ใo ativa lan็ada para o dia de hoje"###"Aten็ใo"###"Inclusใo Prescri็ใo"
					lRet := .F.
					Exit
				Endif
			Next nGhv
			If lRet
				If cOpcBot ==  "5"
					aMntPad := FS_MNTPAD()
				Endif
				If !Empty(aMntPad) .Or. cOpcBot == "1"
					FS_MNTCOL(@aCDatAtu)
					oGHV:AddLine(.T.,.F.)
					oGHV:lNewLine := .F.
					nPosPre:= Len(oGHV:aCols)
					FS_ATUGHV(nPosPre, cSeqPre)
					FS_AtriLeg(oGHV:aCols,nPosPre, nGhvStaReg, "BR_VERDE")
					FS_ATUGHX(oGHV:aCols[nPosPre, nGhvSeqPre])
					If cOpcBot == "5"
						FS_PREPAD(aMntPad)
						FS_MNTCOL(@aCDatAtu)
					Endif
				Endif
				oGHX:oBrowse:Refresh()
			Endif
		Endif
		
	ElseIf cOpcBot == "2"  //Copiar prescricao
		cSeqAnt := oGHV:aCols[oGHV:oBrowse:nAt, nGhvSeqPre]
		If !Empty(oGHV:aCols[oGHV:oBrowse:nAt, nGhvDatPre])
			For nGhv := 1 to len(oGHV:aCols)
				If oGHV:aCols[nGhv, nGhvDatPre] == dDatabase .And. oGHV:aCols[nGhv, nGhvStaReg] == "BR_VERDE"
					Hs_MsgInf(STR0029, STR0022, STR0008) //"Jแ existe prescri็ใo ativa lan็ada para o dia de hoje"###"Aten็ใo"###"Copiar Prescri็ใo"
					lRet := .F.
					Exit
				Endif
			Next nGhv
		Else
			Hs_MsgInf(STR0031, STR0022, STR0008) //"Registro nใo possui informa็๕es para serem copiadas."###"Aten็ใo"###"Copiar Prescri็ใo"
			lRet := .F.
		Endif
		If lRet
			oGHV:AddLine(.T.,.F.)
			oGHV:lNewLine := .F.
			nPosPre:= Len(oGHV:aCols)
			FS_ATUGHV(nPosPre, cSeqPre)
			FS_AtriLeg(oGHV:aCols,nPosPre, nGhvStaReg, "BR_VERDE")
			FS_ATUGHX(cSeqAnt, ,cOpcBot)
			
			For nPosPre := 1 to len(oGhx:aCols)
				oGHX:aCols[nPosPre, nGhxSeqIte] := ""
			Next nPosPre
			oGHX:oBrowse:Refresh()
			
			FS_MNTCOL(@aCDatAtu)
		Endif
		
	ElseIf cOpcBot == "3" //suspender prescricao
		If !Empty(oGHV:aCols[oGHV:oBrowse:nAt, nGhvDatPre]) .And. (oGHV:aCols[oGHV:oBrowse:nAt, nGhvStaReg] $ "BR_VERDE/BR_CINZA")
			If !Empty(oGHX:aCols[1, nGhxTpItmp])
				FS_SUSPRE(oGhv, oGHV:oBrowse:nAt, nGhvMotivo, nGhvDesMot, nGhvStaReg, nGhvUsuSus, nGhvDatSus, nGhvHorSus)
			Else
				Hs_MsgInf(STR0032, STR0022, STR0010) //"Prescri็ใo nใo pode ser suspensa."###"Aten็ใo"###"Suspender prescri็ใo"
				lRet := .F.
			Endif
		Else
			Hs_MsgInf(STR0032, STR0022, STR0010) //"Prescri็ใo nใo pode ser suspensa."###"Aten็ใo"###"Suspender prescri็ใo"
			lRet := .F.
		Endif
		
	ElseIf cOpcBot == "4"  //suspender item prescricao
		If !Empty(oGHX:aCols[oGHX:oBrowse:nAt, nGhxTpItmp]) .And. oGHX:aCols[oGHX:oBrowse:nAt, nGhxStaReg] == "BR_VERDE"
			FS_SUSPRE(oGhx, oGHX:oBrowse:nAt, nGhxMotivo, nGhxDesMot, nGhxStaReg, nGhxUsuSus, nGhxDatSus, nGhxHorSus)
		Else
			Hs_MsgInf(STR0032, STR0022, STR0010) //"Prescri็ใo nใo pode ser suspensa."###"Aten็ใo"###"Suspender prescri็ใo"
			lRet := .F.
		Endif
	ElseIf cOpcBot == "6" // Imprime prescricao
		If !Empty(oGHV:aCols[oGHV:oBrowse:nAt, nGhvDatPre]) .And. oGHV:aCols[oGHV:oBrowse:nAt, nGhvStaReg] <> "BR_VERDE"
			If Empty(oGHV:aCols[oGHV:oBrowse:nAt, nGhvImpVia])
				oGHV:aCols[oGHV:oBrowse:nAt, nGhvImpVia] := "0"
			ElseIf oGHV:aCols[oGHV:oBrowse:nAt, nGhvImpVia] <> "1"
				oGHV:aCols[oGHV:oBrowse:nAt, nGhvImpVia] := "1"
			Endif
			cImpVia := HS_RDescrB("GHV_IMPVIA", oGHV:aCols[oGHV:oBrowse:nAt, nGhvImpVia])                                                                                                            
			
			//logica para pegar o status copiada do metodo FS_GRVABQ
			cStatus := Str(aScan(aLegGhv, {| aVet | aVet[2] == oGHV:aCols[oGHV:oBrowse:nAt, nGhvStaReg]}) - 1, 1)
			cStatus := IIf(cStatus $ '3|4', "3", cStatus)
			cStatus := HS_RDescrB("GHV_STATUS", cStatus)
			
			cNomPac := IIF(!Empty(cTpNasc), M->GB2_NOME, M->GCY_NOME)
			cIdade	 := IIF(!Empty(cTpNasc), HS_A58Age(M->GB2_DTNASC), M->GCY_IDADE)
			cCodLoc := IIF(!Empty(cTpNasc),  HS_IniPadr("GAV", 2, M->GCY_REGATE + cTpNasc, "GAV_CODLOC",,.F.), M->GCY_CODLOC)
			cQuaint := IIF(!Empty(cTpNasc), GAV->GAV_QUARTO, M->GCY_QUAINT)
			cLeiInt := IIF(!Empty(cTpNasc), GAV->GAV_LEITO , M->GCY_LEIINT)
			
			For nPosImp := 1 to len(oGHX:aCols)
				If !Empty(oGHX:aCols[nPosImp, nGhxTpItmp]) .And. !oGHX:aCols[nPosImp, len(oGHX:aCols[nPosImp])]
					aAdd(aMntImp, {M->GCY_REGATE, M->GCY_REGGER, cNomPac, cQuaint, cLeiInt, cCodLoc, oGHV:aCols[oGHV:oBrowse:nAt, nGhvCodCrm], M->GCY_DATATE,;
					oGHV:aCols[oGHV:oBrowse:nAt, nGhvDatPre], oGHV:aCols[oGHV:oBrowse:nAt, nGhvHorCri],oGHX:aCols[nPosImp, nGhxSeqIte], oGHX:aCols[nPosImp, nGhxTpItmp],;
					oGHX:aCols[nPosImp, nGhxAprese], oGHX:aCols[nPosImp, nGhxApresd], oGHX:aCols[nPosImp, nGhxCditmp], oGHX:aCols[nPosImp, nGhxDsfrqa], oGHX:aCols[nPosImp, nGhxIdregi],;
					oGHX:aCols[nPosImp, nGhxDispar], oGHX:aCols[nPosImp, nGhxCdFrqa], cImpVia, cStatus, oGHX:aCols[nPosImp, nGhxObsReg], ;
					oGHX:aCols[nPosImp, nGhxVolume], oGHX:aCols[nPosImp, nGhxDesVia], oGHX:aCols[nPosImp, nGhxVelInf], oGHX:aCols[nPosImp, nGhxDsMinf], oGHX:aCols[nPosImp, nGhxCdMedi],oGHX:aCols[nPosImp, nGhxDesMot],cIdade})
				Endif
			Next nPosImp
			If !Empty(aMntImp)
				If ExistBlock("HSABQRPR")
					ExecBlock("HSABQRPR",.F.,.F.,{aMntImp})
				Else
					HSPAHR22(aMntImp,lCertDig)
				EndIf
			Else
				Hs_MsgInf(STR0033, STR0022, STR0034) //"Prescri็ใo nใo pode ser impressa."###"Aten็ใo"###"Impressใo prescri็ใo"
				lRet := .F.
			Endif
		Else
			Hs_MsgInf(STR0033, STR0022, STR0034) //"Prescri็ใo nใo pode ser impressa."###"Aten็ใo"###"Impressใo prescri็ใo"
			lRet := .F.
		Endif
	ElseIf cOpcBot == "7"
		If !Empty(oGHV:aCols[oGHV:oBrowse:nAt, nGhvDatPre]) .And. oGHV:aCols[oGHV:oBrowse:nAt, nGhvStaReg] == "BR_VERDE"
			HS_PreMed(oGHX, nGhxAprese, M->GCY_CODLOC, LEN(GHX->GHX_APRESE), nGhxCdMedi, nGhxCdItpo, M->GCY_REGATE, nGhxVolume, nGhxCodVia, nGhxVelInf,;
			nGhxCdMinf, nGhxCdFrqa, nGhxObsreg)
			                                                                                                                                                         
			FS_MNTCOL(@aCDatAtu)
		Else
			Hs_MsgInf(STR0052, STR0022, STR0034) //"Item nใo pode ser lan็ado, pois, prescri็ใo nใo esta ativa."###"Aten็ใo"###"Impressใo prescri็ใo"
			lRet := .F.
		Endif

		oGHX:oBrowse:Refresh()
		oGHX:Refresh()      

		oGHV:oBrowse:Refresh()
		oGHV:Refresh()      
	ElseIf cOpcBot == "9"
		HSCerDigOP(oGHV)
	Else
		If !Empty(oGHV:aCols[oGHV:oBrowse:nAt, nGhvDatPre]) .And. oGHV:aCols[oGHV:oBrowse:nAt, nGhvStaReg] == "BR_VERDE"  .And. !Empty(oGHX:aCols[1, nGhxTpItmp])
			FS_AtriLeg(oGHV:aCols,oGHV:oBrowse:nAt, nGhvStaReg, "BR_CINZA")
			
			For nPosTip := 1 to len(aTpItem)
				For nPosPre := 1 to len(oGHX:aCols)
					If (oGHX:aCols[nPosPre, nGhxTpItmp] $ aTpItem[nPosTip]) .And. (!oGHX:aCols[nPosPre, len(oGhx:aCols[nPosPre])])
						cSoma := Soma1(cSoma, len(cSoma))
						oGHX:aCols[nPosPre, nGhxSeqIte] := cSoma
					Endif
				Next nPosPre
			Next nPosTipo
			FS_MNTCOL(@aCDatAtu)
			aSort(oGHX:aCols,,, {| X, Y| X[nGhxSeqIte] + X[nGhxItemBr] < Y[nGhxSeqIte] + Y[nGhxItemBr]})
			
			oGHX:oBrowse:Refresh()
			oGHX:Refresh()      

			
			FS_GRVAbq(cTpNasc)
			FS_ATUGHX(oGHV:aCols[oGHV:oBrowse:nAt, nGhvSeqPre])
			FS_MNTCOL(@aCDatAtu)
			
			oGHV:oBrowse:Refresh()
			oGHV:Refresh()      
            //Chama impressao para certificacao digital
            If GetNewPar("MV_HSPCERD","0") == "1"
				FS_TratFun("6", nOpc,, cTpNasc, .T. ) 
			Endif	
		Else
			Hs_MsgInf(STR0057, STR0022, STR0058) //"Prescri็ใo nใo pode ser encerrada."##"Encerramento prescri็ใo"
			lRet := .F.
		Endif
	Endif
Endif  
            
oGHX:oBrowse:Refresh()
oGHX:Refresh()      

oGHV:oBrowse:Refresh()
oGHV:Refresh()      


 RestArea(aArea)
Return(lRet)

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ATUGHX  บ Autor ณ MARIO ARIZONO      บ Data ณ  11/05/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que atualiza os dados mostrados na getdados dos itensบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Static Function FS_ATUGHX(cSeqPre, aCDatAtu,cOpcBot)
 Local nPosGd := 0
 Default cOpcBot := ""
 aHGHX := {}
 aCGHX := {} 
 nUGHX := 0
 
 nPosGd := aScan(aCDatAtu, {| aVet | aVet[1] == cSeqPre})
 
If nPosGd == 0

	If cOpcBot=="2"
		HS_BDados("GHX", @aHGHX, @aCGHX, @nUGHX, 1,, "GHX->GHX_SEQPRE == '"+ cSeqPre + "' AND GHX->GHX_REGATE == '" + M->GCY_REGATE + "' AND GHX_TPITMP <> '5' AND GHX_TPUSUA <> '2' AND GHX_STATUS<>'0' ",,"GHX_STATUS",,,,,,,,aLegGhx,,.T.,,,,,,"GHX_SEQITE")
	Else
		HS_BDados("GHX", @aHGHX, @aCGHX, @nUGHX, 1,, "GHX->GHX_SEQPRE == '"+ cSeqPre + "' AND GHX->GHX_REGATE == '" + M->GCY_REGATE + "' AND GHX_TPITMP <> '5' AND GHX_TPUSUA <> '2' ",,"GHX_STATUS",,,,,,,,aLegGhx,,.T.,,,,,,"GHX_SEQITE")	
	Endif
	FS_ACPMEMO(nGhxJustif, @aCGHX,M->GCY_REGATE, nGhxItemBr )
	If Empty(aCGHX[1, nGhxItemBr])
		aCGHX[1, nGhxItemBr] := Soma1(aCGHX[1, nGhxItemBr], Len(aCGHX[1, nGhxItemBr]))
		If oGHV:aCols[oGHV:oBrowse:nAt, nGhvDatPre] == dDataBase
			FS_AtriLeg(aCGHX,1, nGhxStaReg, "BR_VERDE")
		Endif
	EndIf
		
	oGHX:ACols:= aClone(aCGHX)
Else
	oGHX:SetArray(aCDatAtu[nPosGd, 2])
Endif  
  
oGHX:oBrowse:Refresh()
 
Return()  

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MNTCOL  บ Autor ณ MARIO ARIZONO      บ Data ณ  11/05/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que guarda acols da data corrente                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_MNTCOL(aCDatAtu)
 Local nPosGD := 0
      
 If oGHV:aCols[oGHV:oBrowse:nAt, nGhvDatPre] == dDataBase .And. oGHV:aCols[oGHV:oBrowse:nAt, nGhvStaReg] <> "BR_AZUL"
 
  nPosGD := aScan(aCDatAtu, {| aVet | aVet[1] == oGHV:aCols[oGHV:oBrowse:nAt, nGhvSeqPre]})
  
  If nPosGD == 0
   AADD(aCDatAtu,{oGHV:aCols[oGHV:oBrowse:nAt, nGhvSeqPre], aClone(oGHX:aCols)})
  Else
   aCDatAtu[nPosGd, 2] := aClone(oGHX:aCols)
  Endif
  
 Endif 
 
Return(.T.)  

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDOK   บ Autor ณ MARIO ARIZONO      บ Data ณ  29/05/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que valida se existe itens lancados na data corrente บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_VLDOK()
Local nPos 		:= 0, nPosGD := 0
Local lRet 		:= .T.
Local nContDel	:= 0		// Conta os registros deletados
Local nContPre	:= 0		// Conta prescricoes em aberto
Local nX		:= 0
Local n			:= 0
nPos := len(oGHV:aCols)
 
If oGHV:aCols[nPos, nGhvDatPre] == dDataBase .And. oGHV:aCols[nPos, nGhvStaReg] == "BR_VERDE"
   
	nPosGD := aScan(aCDatAtu, {| aVet | aVet[1] == oGHV:aCols[nPos, nGhvSeqPre]})
	If nPosGD == 0
		Hs_MsgInf(STR0035, STR0022, STR0036) //"Nenhum item lan็ado na prescri็ใo ativa."###"Aten็ใo"###"Valida็ใo Prescri็ใo"
		lRet := .F.
	Else 
		If Empty(aCDatAtu[nPosGD][2][1][nGhxTpItmp])
			Hs_MsgInf(STR0035, STR0022, STR0036) //"Nenhum item lan็ado na prescri็ใo ativa."###"Aten็ใo"###"Valida็ใo Prescri็ใo"
			lRet := .F.
		Endif
	Endif
Endif   

For nX := 1 To Len(oGHV:aCols)
	If oGHV:aCols[nX, nGhvStaReg] == "BR_VERDE"	// Verifica se a prescricao esta em aberto
		nContPre ++
		If oGHV:oBrowse:nAt == Len(oGHV:aCols)
			For n := 1 To Len(oGHX:aCols)
				If oGHX:aCols[n,Len(oGHX:aHeader) + 1] == .T.	// Verifica se o item esta deletado
					nContDel++
					If nContDel == Len(oGHX:aCols)
						Hs_MsgInf(STR0074, STR0022, STR0036) //"Nใo podem ser excluํdos todos os itens desta prescri็ใo."###"Aten็ใo"###"Valida็ใo Prescri็ใo"
						lRet := .F.
					EndIf
				EndIf
			Next n 
		Else
			For n := 1 To Len(aCDatAtu[n,2])
				If aCDatAtu[nContPre,2,n,Len(oGHX:aHeader) + 1] == .T.	// Verifica se o item esta deletado
					nContDel++
					If nContDel == Len(aCDatAtu[nContPre,2])
						Hs_MsgInf(STR0073 + aCDatAtu[nContPre,1] , STR0022, STR0036) //"Nใo podem ser excluํdos todos os itens da prescri็ใo. Seq. Prescri็ใo: "###"Aten็ใo"###"Valida็ใo Prescri็ใo"
						lRet := .F.
					EndIf
				EndIf
			Next n 
		EndIf
	EndIf
Next nX

Return(lRet)     


Function FS_GerLeg()
Local aLegenda := {{"BR_VERDE"   , STR0037 }, ;  //"Ativa"
                   {"BR_VERMELHO", STR0038}, ;  //"Suspensa"
                   {"BR_AZUL"   , STR0039},; //"Administrada"
                   {"BR_PINK"   , STR0076},; //"Atrasada"
                   {"BR_CINZA"  , STR0059}} //"Encerrada"  

BrwLegenda(STR0040, STR0019, aLegenda) //"Prescri็ใo M้dica"###"Legenda"
Return(Nil)
             

Static Function FS_AtriLeg(aCols, nPosnAt, nPosStat, cCorAtri)

 aCols[nPosnAt, nPosStat] := cCorAtri
 
Return(.T.) 


/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SUSPRE  บ Autor ณ MARIO ARIZONO      บ Data ณ  16/05/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para tratamento da suspensao da prescricao           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_SUSPRE(oObj, nPosAtu, nMotivo, nDesMot, nStaReg, nUsuSus, nDatSus, nHorSus) 
 Local aArea 		:= GetArea()
 Local lRet 			:= .F.
 Local oDlgMot, oMotivo,  oDesMot, nOpcA := 0
 Local	cCadastro := OemToAnsi(STR0041)  //"Motivo de Suspensใo"
 Private cCodMot  := SPACE(LEN(GHS->GHS_MOTIVO))
 Private cDesMot  := SPACE(LEN(GHS->GHS_DESMOT)) 
                                                               
     
 DEFINE MSDIALOG oDlgMot TITLE cCadastro From 09, 00 to 18, 80 of oMainWnd
 
 	@ 040, 015 Say STR0042 Of oDlgMot Pixel COLOR CLR_BLUE //"Motivo"
	 @ 038, 032 MsGet oMotivo VAR cCodMot VALID HS_VldMot(cCodMot, @cDesMot, oDescri) F3 "GHS001" Picture "@!" OF oDlgMot Pixel
	 @ 038, 072 MsGet oDescri VAR cDesMot OF oDlgMot Pixel
  oDescri:lReadOnly := .T. 
	 
	ACTIVATE MSDIALOG oDlgMot CENTERED ON INIT EnchoiceBar(oDlgMot, 	{|| nOpcA := 1, oDlgMot:End()}, ;
																																																																		{|| nOpcA := 0, oDlgMot:End()})
	
	If nOpcA == 0
		Return .T.
 Else
  If !Empty(cCodMot) .And. !Empty(cDesMot)
   oObj:aCols[nPosAtu, nMotivo] := cCodMot
   oObj:aCols[nPosAtu, nDesMot] := cDesMot
   oObj:aCols[nPosAtu, nStaReg] := "BR_VERMELHO"
   oObj:aCols[nPosAtu, nUsuSus] := cUserName
   oObj:aCols[nPosAtu, nDatSus] := dDataBase
   oObj:aCols[nPosAtu, nHorSus] := Time()
   oObj:oBrowse:Refresh()
	 Endif
	EndIf
 
 RestArea(aArea)

Return()

Function HS_VLDMOT(cCodMot, cDesMot, oDesCri)       
 Local lRet := .T.
 
 If !Empty(cCodMot)
  cDesmot := HS_INIPADR("GHS", 1, cCodMot, "GHS_DESMOT",, .F. ) 
  If Empty(cDesMot)
   Hs_MsgInf(STR0043, STR0022, STR0010) //"Motivo invแlido."###"Aten็ใo"###"Suspender prescri็ใo"
   lRet := .F.
  Endif
 Endif
 If lRet
  oDescri:Refresh()
 Endif
Return(lRet)         

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MntPad  บ Autor ณ MARIO ARIZONO      บ Data ณ  23/05/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para tratamento dos procedim. padroes                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Static Function FS_MntPad()
 Local aRetGHU := {}, oDlgPad, nOpcPad := 0
 Local aHGht := {}, aCGht := {}, oGDGht, nUGht := 0
 Local cAtiPre := "1"
 Local nGht    := 0
 Local aArea := GetArea()
 
 nGht := HS_BDados("GHT", @aHGht, @aCGht, @nUGht, 1, , "GHT->GHT_ATIPRE == '" + cAtiPre+ "'")        
			
	nGhtSeqPre := aScan(aHGht, {| aVet | aVet[2] == "GHT_SEQPRE"})
							
	Define MsDialog oDlgPad Title OemToAnsi(STR0044) From 000, 000 To 250, 800 Of oMainWnd PIXEL  //"Prescri็๕es Padr๕es"
		
		oGDGht := MsNewGetDados():New(013, 001, 120, 400, 0,,,,,,,,,, oDlgPad, aHGht, aCGht)
		oGDGht:oBrowse:BlDblClick := {|| nOpcPad := 1, oDlgPad:End()}
		
		Activate MsDialog oDlgPad Centered ON INIT EnChoiceBar(oDlgPad, {|| nOpcPad := 1, oDlgPad:End()}, {|| nOpcPad := 0, oDlgPad:End()})
			
			If nOpcPad == 1  .And. nGht > 0
				DbSelectArea("GHU")
			 DbSetOrder(3)
			 DbSeek(xFilial("GHU") + oGDGht:aCols[oGDGht:nAt, nGhtSeqPre])
			 While !Eof() .and. GHU->GHU_FILIAL == xFilial("GHU") .and. GHU->GHU_SEQPRE == oGDGht:aCols[oGDGht:nAt, nGhtSeqPre]
			  aAdd(aRetGHU, {GHU->GHU_TPITMP, GHU->GHU_CDMEDI, HS_PREITEM(GHU->GHU_TPITMP, GHU->GHU_CDMEDI), GHU->GHU_CDITMP, GHU->GHU_APRESE,;
				                GHU->GHU_APRESD, GHU->GHU_CDITPO, GHU->GHU_CDFRQA, HS_IniPadr("GFZ", 1, GHU->GHU_CDFRQA, "GFZ_DSFRQA",, .F.),;
				                GHU->GHU_CDITUC, GHU->GHU_CDUNIC, HS_IniPadr("SAH", 1, GHU->GHU_CDUNIC, "AH_UMRES",, .F.), GHU->GHU_IDREGI,;
				                GHU->GHU_OBSREG, GHU->GHU_VOLUME, GHU->GHU_CODVIA, HS_IniPadr("GFW", 1, GHU->GHU_CODVIA, "GFW_DESVIA",, .F.),;
				                GHU->GHU_CDMINF,HS_IniPadr("GFY", 1, GHU->GHU_CDMINF, "GFY_DSMINF",, .F.), GHU->GHU_VELINF, GHU->GHU_QTDMED})
				    				 
				 DbSelectArea("GHU")				 
				 DbSkip()
			 End
		 Endif
	
	RestArea(aArea)		
Return(aRetGHU)

Function HS_PacAbq(cAliasAbq, nRegAbq, nOpcAbq)
 Local aArea := GetArea()
 Local cCodPac   := ""

 HS_PosSX1({{"HSABQA","01", GCY->GCY_REGGER}})

 If !Pergunte("HSABQA", .T.)
 	Return()	
 EndIf  

 If !Empty(MV_PAR01) .and. MV_PAR01 <> GCY->GCY_REGGER    
  cCodPac := MV_PAR01  
 Else
  cCodPac := GCY->GCY_REGGER
 Endif 

 DbSelectArea("GBH")              
 DbSetOrder(1)
 If DbSeek(xFilial("GBH") + cCodPac)

  HS_A58("GBH", GBH->(RecNo()), nOpcAbq)          
  
 Else
 
  HS_MsgInf(STR0045, STR0022, STR0046 ) //"Prontuแrio nใo encontrado."###"Aten็ใo"###"Valida็ใo do Prontuแrio"
 
 EndIf 
  
 RestArea(aArea)
Return(Nil)         

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDDEL  บ Autor ณ MARIO ARIZONO      บ Data ณ  29/05/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que valida os itens que poderao ser deletados.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_VLDDEL()
 Local lRet := .T.    
 
 If Empty(oGHX:aCols[oGHX:oBrowse:nAt, nGhxAprese]) .And. oGHX:aCols[oGHX:oBrowse:nAt, nGhxTpItmp] == "1"
  Hs_MsgInf(STR0047, STR0022, STR0048) //"Item nใo pode ser deletado, pois nใo possui apresenta็ใo lan็ada."###"Aten็ใo"###"Valida็ใo dele็ใo"
  lRet := .F.
 ElseIf oGHX:aCols[oGHX:oBrowse:nAt, nGhxStaReg] <> "BR_VERDE"
  Hs_MsgInf(STR0049, STR0022, STR0048) //"Item suspenso nใo pode ser deletado."###"Aten็ใo"###"Valida็ใo dele็ใo"
  lRet := .F.
 Endif 
    
Return(lRet)        

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VLWHEN  บ Autor ณ MARIO ARIZONO      บ Data ณ  29/05/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que valida os itens que poderao ser alterados.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

FUNCTION HS_VLWHEN()
 Local lRet := .T.    
  
 If oGHX:aCols[oGHX:oBrowse:nAt, nGhxStaReg] == "BR_VERMELHO"
  lRet := .F.
 Endif 
    
Return(lRet)        
                     

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ATUSTA  บ Autor ณ MARIO ARIZONO      บ Data ณ  29/05/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que preenche status de datas passadas.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

FUNCTION FS_ATUSTA()
 Local nGhv := 0
  
 For nGhv := 1 to len(oGhv:aCols)
   
  If oGhv:aCols[nGhv, nGhvStaReg] == "BR_CINZA" .And. oGhv:aCols[nGhv, nGhvDatPre] < dDataBase .And. ! Empty(oGhv:aCols[nGhv, nGhvDatPre])
   oGhv:aCols[nGhv, nGhvStaReg] := "BR_PINK"
  Endif  
 
 Next nGhv    
 oGhv:oBrowse:Refresh()
Return() 

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PREPAD  บ Autor ณ MARIO ARIZONO      บ Data ณ  26/02/08  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que preenche itens da prescricao com dados da        บฑฑ
ฑฑบ          ณprescricao padrao.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Static Function FS_PREPAD(aPrePad) 
 Local nPosPad := 0
 Local aArea   := GetArea() 
 For nPosPad := 1 to len(aPrePad)
  If nPosPad > 1
   oGHX:AddLine(.T.,.F.)
   oGHX:lNewLine := .F.
  Endif
  FS_AtriLeg(oGHX:aCols,nPosPad, nGhxStaReg, "BR_VERDE")
  oGHX:aCols[nPosPad, nGhxTpItmp] := aPrePad[nPosPad, 1]
  oGHX:aCols[nPosPad, nGhxCdMedi] := aPrePad[nPosPad, 2]
  oGHX:aCols[nPosPad, nGhxDsItem] := aPrePad[nPosPad, 3]
  oGHX:aCols[nPosPad, nGhxCdItmp] := aPrePad[nPosPad, 4]
  oGHX:aCols[nPosPad, nGhxAprese] := aPrePad[nPosPad, 5]
  oGHX:aCols[nPosPad, nGhxApresD] := aPrePad[nPosPad, 6]
  oGHX:aCols[nPosPad, nGhxCdItpo] := aPrePad[nPosPad, 7]
  oGHX:aCols[nPosPad, nGhxCdFrqa] := aPrePad[nPosPad, 8]
  oGHX:aCols[nPosPad, nGhxDsFrqa] := aPrePad[nPosPad, 9]
  oGHX:aCols[nPosPad, nGhxCdItuc] := aPrePad[nPosPad, 10]
  oGHX:aCols[nPosPad, nGhxCdunic] := aPrePad[nPosPad, 11]
  oGHX:aCols[nPosPad, nGhxDunico] := aPrePad[nPosPad, 12]          
  oGHX:aCols[nPosPad, nGhxIdRegi] := aPrePad[nPosPad, 13]
  oGHX:aCols[nPosPad, nGhxObsReg] := aPrePad[nPosPad, 14]
  oGHX:aCols[nPosPad, nGhxVolume] := aPrePad[nPosPad, 15]
  oGHX:aCols[nPosPad, nGhxCodVia] := aPrePad[nPosPad, 16]
  oGHX:aCols[nPosPad, nGhxDesVia] := aPrePad[nPosPad, 17]
  oGHX:aCols[nPosPad, nGhxCdMinf] := aPrePad[nPosPad, 18]
  oGHX:aCols[nPosPad, nGhxDsMinf] := aPrePad[nPosPad, 19]          
  oGHX:aCols[nPosPad, nGhxVelInf] := aPrePad[nPosPad, 20]
  oGHX:aCols[nPosPad, nGhxQtdMed] := aPrePad[nPosPad, 21]
    
  If !Empty(M->GCY_CODLOC)
   DbSelectArea("GNL")
   DbSetOrder(2)
   If DbSeek(xFilial("GNL") + aPrePad[nPosPad, 2] + M->GCY_CODLOC)
    oGHX:aCols[nPosPad, nGhxDispar] := GNL->GNL_DISPAR
    oGHX:aCols[nPosPad, nGhxObserv] := GNL->GNL_OBSERV
   Endif
  Endif               
 Next nPosPad

oGHX:oBrowse:Refresh()
oGHX:Refresh()      			 

 RestArea(aArea)
Return(nil)  

        

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ATUGHV  บ Autor ณ MARIO ARIZONO      บ Data ณ  05/03/08  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que preenche cabecalho da prescricao.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/


Static Function FS_ATUGHV(nPos, cSeqPre)
 Local aArea := GetArea()
 
 If !Empty(cSeqPre) .And. oGHV:aCols[nPos, nGhvSeqPre] <= cSeqPre
  oGHV:aCols[nPos, nGhvSeqPre] := Soma1(cSeqPre, len(GHV->GHV_SEQPRE))
 Endif
 oGHV:aCols[nPos, nGhvDatPre] := dDataBase   
 oGHV:aCols[nPos, nGhvHorCri] := Time()
 oGHV:aCols[nPos, nGhvCodCrm] := aCodUsr[2] 
 oGHV:aCols[nPos, nGhvNomMed] := HS_IniPadr("SRA", 11, aCodUsr[2], "RA_NOME")  
 oGHV:oBrowse:Refresh()
 oGHV:Refresh()      			 
 
 RestARea(aArea)
Return(Nil)
                

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MAXGHV  บ Autor ณ MARIO ARIZONO      บ Data ณ  10/04/08  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que retorna o ultimo sequencial utilizado na presc.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Static Function FS_MAXGHV(cRegate)
 Local aArea   := GetArea()
 Local cSql    := ""
 Local cSeqPre := ""
  
 cSql := " SELECT MAX(GHV.GHV_SEQPRE) GHV_MAX"
	
	cSql += " 	FROM " + RetSQLName("GHV") + " GHV"

	cSql += " 	WHERE GHV.GHV_FILIAL =  '" + xFilial("GHV") + "'" 
 cSql += "  		AND GHV.D_E_L_E_T_ <> '*'"
 cSql += "  		AND GHV.GHV_REGATE =  '" + cRegate + "'" 
 
 cSql := ChangeQuery(cSql)

 TCQUERY cSql NEW ALIAS "QRY"
 	
 cSeqPre := IIf(!Empty(QRY->GHV_MAX), QRY->GHV_MAX, STRZERO(0, LEN(GHV->GHV_SEQPRE))) 
 DbCloseArea()
  
 RestArea(aArea)
Return (cSeqPre)

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณHS_PREITEM บ Autor ณ MARIO ARIZONO      บ Data ณ  18/04/08  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que preenche descricao do item da prescricao         บฑฑ
ฑฑบ          ณmedicamento/dieta/cuidado.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Function HS_PREITEM(cTipIte, cCodigo, lDic)
 Local cDescri  := ""
 
 Default lDic := .T.

 If !Empty(cTipIte) .And. IIF(lDic, !Inclui, .T.)
  If cTipIte $ "1/4"
   cDescri :=  HS_IniPadr("SB1", 1, cCodigo, "B1_DESC",, .F.)
  ElseIf cTipIte == "2"
   cDescri :=  HS_IniPadr("SX5", 1, "TE" + PadR(AllTrim(cCodigo), Len(SX5->X5_CHAVE)), "X5_DESCRI",,.F.)
  Else
   cDescri :=  HS_IniPadr("GNP", 1, cCodigo, "GNP_DESCUI",, .F.)
  Endif
 Endif
   
Return (cDescri)

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RETKIT  บ Autor ณ MARIO ARIZONO      บ Data ณ  18/04/08  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que preenche descricao do item da prescricao         บฑฑ
ฑฑบ          ณmedicamento/dieta/cuidado.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Function FS_RETKIT(cMedican, cCodVia)
 Local cCodKit := ""
 Local aArea   := GetArea(), aRetKit := {}
 Local nCont   := 0
  
 DbSelectArea("GAF")
 DbSetOrder(4)
 If DbSeek(xFilial("GAF") + cMedican)
  While !Eof() .And. xFilial("GAF") == GAF->GAF_FILIAL .And. GAF->GAF_CCOKIT == cMedican
   If !Empty(cCodVia) .And. cCodVia == GAF->GAF_CODVIA
    cCodKit := GAF->GAF_CODKIT
    Exit
   Else  
    If nCont < 1
     cCodKit := GAF->GAF_CODKIT
    Endif
    nCont++
   Endif
  
   dbSkip()
  End
 Endif
 
 If !Empty(cCodKit) 
  DbSelectArea("GAG")
  DbSetOrder(1)
  IF DbSeek(xFilial("GAG") + cCodKit + cMedican)
   While !Eof() .And. xFilial("GAG") == GAG->GAG_FILIAL .And. GAG->GAG_CODKIT == cCodKit 
    IF GAG->GAG_CCOKIT <> cMedican
     Aadd(aRetKit,{GAG->GAG_CODKIT, GAG->GAG_CCOKIT, GAG->GAG_QTDKIT})
    Endif
 
   DbSkip()
   End
  Endif  
 Endif 
  
 RestArea(aArea)  
Return (aRetKit)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TipPre บ Autor ณ Mario Arizono      บ Data ณ  07/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao utilizada para tratar a descricao do campo combo.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar 																					             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_TipPre()

Local cDescri := ""
If FunName() $ "HSPAHABQ/HSPAHA90/HSPAHR22/HSPAHM30/HSPAHMA7"
 cDescri := "1=Medicamento;2=Dieta;3=Cuidado;4="+ CHR(187) + " Med. Composto;5="+ CHR(187) + " Kit;6="+ CHR(187) + " Associado;7=Material "
Else
 cDescri := "1=Medicamento;2=Dieta;3=Cuidado;4=Med. Composto;5=Kit;6=Associado;7=Material "
Endif 
Return(cDescri)        


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_HorEnf บ Autor ณ Mario Arizono      บ Data ณ  28/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao utilizada montar horarios de suspensใo.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar 																					             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_HorEnf(cRegate, cSeqPre)

Local oGnr
Local aHGnr := {}, aCGnr := {}
Local nUGnr := 0, nPos := 0, nDados := 0, nOpc := 0
Local aLegGNR := {{"GNR_STATUS == '0'","BR_VERDE"},    {"GNR_STATUS == '1'","BR_AMARELO"},;
                   {"GNR_STATUS == '2'","BR_VERMELHO"}, {"GNR_STATUS == '3'","BR_PRETO"}}
 
aJoin := {{" LEFT JOIN " + RetSqlName("GHS") + " GHS", "GHS.GHS_DESMOT", "GHS.GHS_FILIAL = '" + xFilial("GHS") + "' AND GHS.D_E_L_E_T_ <> '*' AND GHS.GHS_MOTIVO = GNR.GNR_MOTIVO", "GNR_DESMOT"}}    

nDados := HS_BDados("GNR", @aHGNR, @aCGNR, @nUGNR, 1,, "GNR->GNR_PRODUT = '"+ oGHX:aCols[oGHX:oBrowse:nAt, nGhxCdMedi] + "' AND GNR->GNR_SEQPRE = '"+ oGHV:aCols[oGHV:oBrowse:nAt, nGhvSeqPre] + ;
                    "' AND GNR->GNR_ITEPRE = '"+ oGHX:aCols[oGHX:oBrowse:nAt, nGhxItemBr] + "' AND GNR->GNR_REGATE = '"+ cRegate + "' AND  GNR->GNR_DEVOLV = '0' AND GNR->GNR_ADMINI = '0' ",,;
                    "GNR_STATUS", "GNR_HORPRE/GNR_MOTIVO/GNR_DESMOT/GNR_ITEPRE",,,, "GNR_STASUS","IIF(GNR_STASUS = '1', 'LBTIK','LBNO')", .T.,aLegGnr)
 
 If nDados == 0
  HS_MsgInf(STR0062, STR0022, STR0063)  //"Nenhum horแrio gerado para o medicamento selecionado."##"Valida็ใo hoแrios gerados"
  Return(Nil) 
 Else
  If oGHV:aCols[oGHV:oBrowse:nAt, nGhvStaReg] $ "BR_AZUL/BR_VERMELHO"
   HS_MsgInf(STR0064, STR0022, STR0063)//"Para o status atual da prescri็ใo, os horแrios nใo poderใo ser suspensos."##"Valida็ใo hoแrios gerados"
   Return(Nil)
  ElseIf oGHX:aCols[oGHX:oBrowse:nAt, nGhxStaReg] == "BR_VERMELHO"
   HS_MsgInf(STR0065, STR0022, STR0063)//"Medicamento jแ se encontra suspenso."##"Valida็ใo hoแrios gerados"
   Return(Nil) 
  Endif
 Endif
 
 nGnrStatus := aScan(aHGnr, {| aVet | aVet[2] == "GNR_STATUS"})
 nGnrHorari := aScan(aHGnr, {| aVet | aVet[2] == "GNR_HORPRE"})
 nGnrMarcad := aScan(aHGnr, {| aVet | aVet[2] == "GNR_STASUS"})
 nGnrMotivo := aScan(aHGnr, {| aVet | aVet[2] == "GNR_MOTIVO"})
 nGnrItePre := aScan(aHGnr, {| aVet | aVet[2] == "GNR_ITEPRE"})
  
	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T.,.T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0066) From 000, 000 To 400, 500 Of oMainWnd PIXEL //"Horแrios para suspensใo"
	oGNR := MsNewGetDados():New(aPObj[1, 1], aPObj[1, 2], aPObj[1, 3], aPObj[1, 4], GD_UPDATE,,,,,,,,,, oDlg, aHGNR, aCGNR)
	oGNR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGNR:oBrowse:BlDblClick := {||  IIF (!(StrZero(oGnr:oBrowse:nColPos, 2) $ StrZero(nGnrMotivo, 2)), FS_DClick(oGnr), oGnr:EDITCELL(oGnr:OBROWSE, oGnr:oBrowse:nAt, oGnr:oBrowse:nColPos))}
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnChoiceBar(oDlg, {|| nOpc := 1, IIf( FS_VLDSUS(oGnr) , oDlg:End(), nOpc := 0)}, {|| nOpc := 0, oDlg:End()}))


 If nOpc == 1
  Begin Transaction
   DbSelectArea("GNR")
   DbSetOrder(2)      
   For nPos := 1 to len(oGNR:aCols)
    If oGNR:aCols[nPos, nGnrMarcad] == "LBTIK"
     DbSeek(xFilial("GNR") + cRegate + cSeqPre + oGNR:aCols[nPos, nGnrItePre] + oGHX:aCols[oGHX:oBrowse:nAt, nGhxCdMedi] +  oGNR:aCols[nPos, nGnrHorari])
      
     Reclock("GNR", .F.)
      GNR->GNR_STASUS := "1"
      GNR->GNR_STATUS := "3"
      GNR->GNR_MOTIVO := oGNR:aCols[nPos, nGnrMotivo]
     MsUnLock()
    Endif
   
   Next nPos
  End Transaction   
 
 
 Endif


Return(Nil) 

Static Function Fs_DClick(oObj)
   
If oObj:aCols[oObj:oBrowse:nAt,nGnrMarcad] == "LBNO"
	oObj:aCols[oObj:oBrowse:nAt,nGnrMarcad] := "LBTIK"
ElseIf oObj:aCols[oObj:oBrowse:nAt,nGnrStatus] <> "BR_PRETO" 
	oObj:aCols[oObj:oBrowse:nAt,nGnrMarcad] := "LBNO"
Endif

oObj:oBrowse:Refresh()

Return(Nil)

Function HS_VLDABQ()
 Local lRet := .T.

 If ReadVar() == "M->GNR_MOTIVO"
  If !HS_SeekRet("GHS", "M->GNR_MOTIVO", 1, .f., "GNR_DESMOT", "GHS_DESMOT")
   Hs_MsgInf(STR0067, STR0022, STR0068) //"C๓digo do motivo invแlido. Verifique."##"Valida็ใo motivo"
   lRet := .F.
  Endif
 Endif

Return(lRet)     

Static Function Fs_VldSus(oGnr)
 Local lRet  := .T.          
 Local nPos  := 0
 Local cHora := ""

 For nPos := 1 to len(oGNR:aCols)
  
  If oGNR:aCols[nPos, nGnrMarcad] == "LBTIK" .And. Empty(oGNR:aCols[nPos, nGnrMotivo]) .And. oGNR:aCols[nPos, nGnrStatus] <> "BR_PRETO"
   If Empty(cHora)
    cHora := oGNR:aCols[nPos, nGnrHorari]
   Else
    cHora += ", " + oGNR:aCols[nPos, nGnrHorari] 
   Endif
  Endif
                                                                                
 Next nPos

 If !Empty(cHora)
  Hs_MsgInf(STR0069 + cHora + STR0070, STR0022, STR0068)//"O(s) seguinte(s) horแrio(s) ["##"] nใo apresenta(m) motivo de suspensใo. Verifique."##"Valida็ใo motivo"
  lRet := .F.
 Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_HorEdi บAutor  ณMicrosiga           บ Data ณ  27/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao criada para habilitar ou nao a digitacao da hora de บฑฑ
ฑฑบ          ณ criacao da prescricao.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_HorEdit()
Local lRet		:= .F.
Local cHorEdit	:= GetNewPar("MV_HOREDIT","N")

If cHorEdit == "S" .AND. oGHV:aCols[oGHV:oBrowse:nAt,1] == "BR_VERDE"
	lRet := .T.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSCerDigOP บ Autor ณ Saude            บ Data ณ 20/01/2015  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Habilita opcoes de consulta e alteracao do certificado     บฑฑ
ฑฑบ          ณ digital                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HSCerDigOP(oGDGHV)    
Local nPosSEQPRE := Ascan(oGDGHV:aHeader,{|x|x[2] == "GHV_SEQPRE"})
Local aAreaGHV := GHV->(GetArea())
Local cCertDig := ""
Local cArqPDF  := ""
Local oDlg


DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 

If GHV->(DbSeek(xFilial("GHV")+GCY->GCY_REGATE+oGDGHV:aCols[oGDGHV:nAt][nPosSEQPRE]))  

    cCertDig := E_MSMM(GHV->GHV_ASSDIG)
    cArqPDF  := GHV->GHV_ARQCER
	DEFINE MSDIALOG oDlg TITLE STR0079 FROM 008.0,010.3 TO 034.4,90 // "Assinatura Digital"
   
	@ 010,005 SAY oSay PROMPT STR0080  SIZE 100,010 OF oDlg PIXEL COLOR CLR_RED //"Arquivo PDF"
	@ 020,005 MSGET cArqPDF  PICTURE "@" SIZE 80, 7 PIXEL OF oDlg 
    
	@ 040,005 SAY oSay PROMPT STR0079  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Assinatura Digital"
	@ 050,005 GET oMsg VAR cCertDig MEMO SIZE 310,120 PIXEL OF oDlg 
   
	@ 180,156 BUTTON STR0081  SIZE 36,13 PIXEL ACTION HSCDAcao(1,oDlg,@cArqPDF,@cCertDig) //"&Assinar" 
	@ 180,194 BUTTON STR0082  SIZE 36,13 PIXEL ACTION HSCDAcao(2) //"&Validar Cert."
	@ 180,232 BUTTON STR0083  SIZE 36,13 PIXEL ACTION HSCDAcao(3,oDlg,@cArqPDF,@cCertDig) //"Visualizar &PDF"
	@ 180,270 BUTTON STR0084  SIZE 36,13 PIXEL ACTION oDlg:End() //"&Cancelar" 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ativa dialogo....                                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ACTIVATE MSDIALOG oDlg CENTERED 
EndIf

RestArea(aAreaGHV)

Return         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSCDAcao   บ Autor ณ Saude            บ Data ณ 20/01/2015  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa acoes da opcao de Certificado Digital              บฑฑ
ฑฑบ          ณ digital                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HSCDAcao(nOpc,oDlg,cArqPDF,cCertDig) 
Local cPathServer := ""
Local cPathLocal  := ""
Local aRetPath    := {}
Local cQuaint     := ""
Local cLeiInt     := ""
Local cImpVia     := ""   
Local cStatus     := "" 

Do Case  
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Realiza a assinatura do certificado digital	                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case nOpc == 1
		If GHV->GHV_STAASS == "1"
			MsgInfo(STR0085) //"A prescri็ใo selecionada jแ foi assinada digitalmente."
		Else
			GB1->(DbSetOrder(1))//GB1_FILIAL+GB1_REGATE+DTOS(GB1_DATAE)+GB1_HORAE
			GHX->(DbSetOrder(4))//GHX_FILIAL + GHX_SEQPRE + GHX_REGATE + GHX_SEQITE
			
			If GHX->(DbSeek(xFilial("GHX")+GHV->(GHV_SEQPRE + GHV_REGATE))) 
				aMntImp := {}      
				While GHV->(GHV_SEQPRE+GHV_REGATE) == GHX->(GHX_SEQPRE+GHX_REGATE) .And. !GHX->(Eof())
					
					GFZ->(DbSetOrder(1))
					GFW->(DbSetOrder(1))
					GFY->(DbSetOrder(1))
					GHS->(DbSetOrder(1))
					
					If GB1->(DbSeek(xFilial("GB1")+GHV->GHV_REGATE+Dtos(GCY->GCY_DATATE)))
						While GHV->GHV_REGATE+Dtos(GCY->GCY_DATATE) == GB1->GB1_REGATE+Dtos(GB1->GB1_DATAE) .And. !GB1->(Eof())
							If GHV->GHV_DATPRE >= GB1->GB1_DATAE .And. (GHV->GHV_DATPRE <= GB1->GB1_DATAS .Or. Empty(GB1->GB1_DATAS)) 
								cQuaint := GB1->GB1_QUARTO
								cLeiInt := GB1->GB1_LEITO
								Exit
							EndIf
							GB1->(DbSkip())
						EndDo
					EndIf
					
				   GHV->(RecLock("GHV",.F.))
					If Empty(GHV->GHV_IMPVIA)
			   			GHV->GHV_IMPVIA := "0"
		   			ElseIf GHV->GHV_IMPVIA <> "1"
			   			GHV->GHV_IMPVIA := "1"
					Endif      
					GHV->(MsUnlock())
					
					cImpVia := HS_RDescrB("GHV_IMPVIA", GHV->GHV_IMPVIA)   
					cStatus := HS_RDescrB("GHV_STATUS", GHV->GHV_STATUS) 
					
				    aAdd(aMntImp, {GHV->GHV_REGATE, GCY->GCY_REGGER, GCY->GCY_NOME, cQuaint, cLeiInt, GCY->GCY_CODLOC, GHV->GHV_CODCRM, GCY->GCY_DATATE,;
					GHV->GHV_DATPRE, GHV->GHV_HORCRI, GHX->GHX_SEQITE, GHX->GHX_TPITMP,;
					GHX->GHX_APRESE, GHX->GHX_APRESD, GHX->GHX_CDITMP, Posicione("GFZ", 1, xFilial("GFZ") + GHX->GHX_CDFRQA, "GFZ_DSFRQA"),; 
					GHX->GHX_IDREGI, GHX->GHX_DISPAR, GHX->GHX_CDFRQA, cImpVia, cStatus, GHX->GHX_OBSREG, ;
					GHX->GHX_VOLUME, Posicione("GFW", 1, xFilial("GFZ") + GHX->GHX_CODVIA, "GFW_DESVIA"), GHX->GHX_VELINF, ; 
					Posicione("GFY", 1, xFilial("GFZ") + GHX->GHX_CDMINF, "GFY_DSMINF"), GHX->GHX_CDMEDI, Posicione("GHS", 1, xFilial("GFZ") + GHX->GHX_MOTIVO, "GHS_DESMOT")})
					
					GHX->(DbSkip())
				    
				EndDo
				
				HSPAHR22(aMntImp,.T.)
			EndIf
			
	   	    cCertDig := E_MSMM(GHV->GHV_ASSDIG)
   			cArqPDF  := GHV->GHV_ARQCER
			oDlg:Refresh()
		EndIf    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida via webservice se uma assinatura ja realizada e valida            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Case nOpc == 2  
		If GHV->GHV_STAASS == "1"     
			HSCertDig("6")
		Else
			MsgInfo(STR0086) //"A prescri็ใo selecionada nใo foi assinada digitalmente."
		EndIf	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Abre arquivo PDF                           		                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Case nOpc == 3 	 
		If GHV->GHV_STAASS == "1"   
			cPathServer := PLSMUDSIS(Alltrim(GHV->GHV_DIRCER)+'\'+cArqPDF)  
			aRetPath := fDirPdfHSP(Alltrim(GHV->GHV_CODCRM),"P")
			If aRetPath[1]
				cPathLocal := aRetPath[2]  
				If CpyS2T(cPathServer,cPathLocal,.T.)
					ShellExecute("Open", cPathLocal+cArqPDF, " /k dir", GetTempPath(), 1 )         
				EndIf	
			Else
            	MsgInfo(aRetPath[2])
			EndIf
		Else
			MsgInfo(STR0086) //"A prescri็ใo selecionada nใo foi assinada digitalmente."
		EndIf	
EndCase
	
Return
