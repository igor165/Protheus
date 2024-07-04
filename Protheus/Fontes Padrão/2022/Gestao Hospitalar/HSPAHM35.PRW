#INCLUDE "HSPAHM35.ch"
#INCLUDE "PROTHEUS.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM35  º Autor ³ MARCELO JOSE       º Data ³  11/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ MOVIMENTACAO DO CENTRO CIRURGICO                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracoes³(09/02/06 - Cibele Peria)                                   º±±
±±º          ³Alteracao tratamento dos tipos de leito nas movimentacoes:  º±±
±±º          ³ *Admissao: o leito de origem nao pode ser dos tipos c.ci - º±±
±±º          ³            rurgico, nem pre, nem pos-operatorio.           º±±
±±º          ³            o leito de destino tem que ser do tipo pre-ope- º±±
±±º          ³            ratorio ou c.cirurgico                          º±±
±±º          ³ *Saida   : o leito de origem deve ser do tipo pos-operato- º±±
±±º          ³            rio ou c.cirurgico                              º±±
±±º          ³ *Trasnf  : somente entre de leitos pre, pos ou c.cirurgico.º±±
±±º          ³            para estes mesmos, mais UTI.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracoes³(24/07/06 - Antonio Carlos)                                 º±±
±±º          ³Criar uma legenda c/cor diferenciada p/pacientes que encon- º±±
±±º          ³tram-se no Centro Cirurgico e tem leito de origem  do  tipo º±±
±±º          ³Espera                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM35()
 Local aCorM35 := {{"GAV->GAV_TIPO == '3'",'BR_VERDE'   }, ;
                   {"GAV->GAV_TIPO == '2' .Or. GAV->GAV_TIPO == '5' .Or. GAV->GAV_TIPO == '6'",'BR_AMARELO' }, ;
                   {"GAV->GAV_TIPO == '1'",'BR_AZUL'    }, ;
                   {"GAV->GAV_TIPO == '4'",'BR_VERMELHO'}, ;
                   {"GAV->GAV_TIPO == '7'",'BR_BRANCO'  }, ;
                   {"GAV->GAV_TIPO == '0'",'BR_CINZA'   }}
                         
 Private cSetPerg   := ""
 Private cFilM35    := ""
 Private lFilGm1    := .T. /* SELECIONA FUNCIONARIO QUE PODE ENTRAR NO SETOR */
 Private cGcsTipLoc := "4" /* SELECIONA TIPO DE LEITO                         */
 Private cGcsCodLoc := ""  /* SELECIONA SETOR DE ENFERMAGEM E CIRURGICO       */
 PRIVATE cGcyAtendi := "0"
 Private cGAVTipo			:= ""  // Var usada na funcao de filtro
 Private cCirCodLoc	:= ""  // Var usada na funcao de filtro
 Private cPerg2     := "HSPM35"
 Private cPerg3     := "HSP35B"
 Private cCadastro  := STR0001   //==> esta variavel (cCadastro) tb esta sendo usado no X1_Valid da pergunta 01 (Setor) do grupo HSP35B //"MOVIMENTACAO DO CENTRO CIRURGICO"
 Private aRotina    := MenuDef()
 
 If FS_FilM35("HSP35A", .F.)
  SetKey(VK_F12, {|| FS_FilM35("HSP35A", .T.) })             
  mBrowse(06, 01, 22, 75, "GAV",,,,,, aCorM35,,,,,,,, cFilM35)
 Endif
 
 SetKey(VK_F12)
Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±      ADMISSAO                                                           ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION HS_M35ADM(cAlias, nReg, nOpc)
Local aArea			:= GetArea()
Local cOldQuarto	:= ""
Local cOldSetor		:= ""
Local cOldLeito		:= ""
Local cOldRegate	:= ""
Local cUsuBloq      := ""
Local nRecNo_Des	:= 0
Local dDataRef		:= dDataBase, cHoraRef := Time()   
Local cResLeit		:= GetMv("MV_RESLEIT",,"1")  // = 0 (O sistema "NÃO" reserva o leito para pacientes admitidos no centro cirurgico) = 1 (O sistema reserva)
Local cQuart:=SPACE(TAMSX3("GAV_QUARTO")[1])
Local cLeito:=SPACE(TAMSX3("GAV_LEITO")[1])

Private cStatusGAV := "0" // Var usada na funcao de filtro

IF Alltrim(cResLeit) <> "0" .AND. Alltrim(cResLeit) <> "1"  .AND. !Empty(cResLeit)
	Hs_MSgInf("Conteudo incorreto no parametro 'MV_RESLEIT'!",STR0051,STR0053)
	Return(Nil)
EndIf   

//Verifica se e RN
DbSelectArea("GB2")
DbSetOrder(1)
If DbSeek(xFilial("GB2") + GAV->GAV_REGATE + GAV->GAV_RESERV)
	HS_MsgInf(STR0064, STR0014, STR0015) //"RN deve ser cadastrado como paciente para admissão no Centro Cir´rgico."###"Atencao"###"Admissao Centro Cirurgico"
	RestArea(aArea)
	Return(Nil)
EndIf

DbSelectArea("GAV")
DbSetOrder(2)   
DbSeek(xFilial("GAV") + GAV->GAV_REGATE)
If GAV->GAV_TIPO $ "2"
	HS_MsgInf(STR0062, STR0014, STR0015) //"Paciente ja adimitido no setor "###"Atencao"###"Admissao Centro Cirurgico"
	RestArea(aArea)
    Return(Nil)
Endif

IF GAV->GAV_TIPO $ "2/5/6"
	HS_MsgInf(STR0010 + ; //"Admissao nao permitida para leitos "
             IIF(GAV->GAV_TIPO == "2", STR0011, ; //"do centro cirurgico"
             IIF(GAV->GAV_TIPO == "5", STR0012, STR0013)), STR0014, STR0015) //"pre-operatorio"###"pos-operatorio"###"Atencao"###"Admissao Centro Cirurgico"
 	RestArea(aArea)
	Return(Nil)
EndIf

cGcsTipLoc := "4"   //SO ADMITE PARA O CENTRO CIRURGICO
cGcsCodLoc := cSetPerg
cGAVTipo			:= "2/5" // Leitos Destino apenas C. Cirurgico ou Pre-operatorio

cOldQuarto := GAV->GAV_QUARTO
cOldSetor  := GAV->GAV_CODLOC
cOldLeito  := GAV->GAV_LEITO
cOldregate := GAV->GAV_REGATE
 
If(GAV->GAV_DATATE > dDataRef ).Or.( (GAV->GAV_DATATE == dDataRef ).And.(GAV->GAV_HORATE > cHoraRef))
	Hs_MSgInf(STR0054+STR0055,STR0051,STR0053) 
	RestArea(aArea) 
	Return(Nil)
ElseIf !(FS_VldData("GCY", ,xFilial("GCY")+cOldregate, "GCY_DATATE", "GCY_HORATE", dDataRef, cHoraRef, STR0054+STR0055) )
 	RestArea(aArea) 
	Return(Nil)
Elseif !(FS_VldData("GB1", 2,xFilial("GB1")+cOldregate+cOldSetor+cOldQuarto+cOldLeito+"", "GB1_DATAE", "GB1_HORAE", dDataRef, cHoraRef, STR0054+STR0056) )
 	RestArea(aArea) 
	Return(Nil)
EndIf
  
If !Pergunte(cPerg2, .T.)
 	RestArea(aArea) 
	Return(Nil)
EndIf
                                               
    If HS_ExisDic({{"C", "GCS_LSTESP"}}, .F.)///lista de espera
			DbSelectArea("GCS")
			DbSetOrder(1)
			Dbseek(xFilial("GCS")+cSetPerg)  //GCS_FILIAL+GCS_CODLOC
			If GCS->GCS_LSTESP =="1"
				DbSelectArea("GT6")
				GT6->(DbSetOrder(1))
				If 	GT6->(DbSeek(xFilial("GT6") + cSetPerg+ MV_PAR01+MV_PAR02))
					cQuart :=MV_PAR01
					cLeito:=MV_PAR02
				Else
					IF GT6->(DbSeek(xFilial("GT5") + cSetPerg+ MV_PAR01))
					If MV_PAR02 == GT6->GT6_LEITO .or. Empty(GT6_LEITO)
						cQuart :=GT6->GT6_QUARTO
						cLeito :=GT6->GT6_LEITO
					Endif	
					Else
						If GT6->(DbSeek(xFilial("GT5") + cSetPerg))
							If  MV_PAR01 == GT6->GT6_QUARTO .or. Empty(GT6_QUARTO)
								cQuart :=GT6->GT6_QUARTO
								cLeito :=GT6->GT6_LEITO
							Endif
						Endif
					Endif
				Endif
				
				If HS_CountTB("GT6", "GT6_CODLOC = '" + cSetPerg + "'  and GT6_QUARTO = '" + cQuart + "' and  GT6_LEITO = '" + cLeito + "'  ") > 0
					HS_ExbLsE(cSetPerg,cQuart,cLeito,nOpc) ///lista de espera
				Endif
			Endif
		Endif


                                               
IF !ApMsgYesNo(STR0016) //"Confirma a Admissao no Leito?"
 	RestArea(aArea)
	Return()
Endif 
   
DbSelectArea("GAV")
DbSetOrder(1)
If !DbSeek(xFilial("GAV") + cSetPerg + MV_PAR01 + MV_PAR02)
	HS_MsgInf(STR0017 + cSetPerg, STR0014, STR0015) //"Leito nao encontrado no setor "###"Atencao"###"Admissao Centro Cirurgico"
 	RestArea(aArea)  
	Return()
Endif 
nRecNo_Des := RecNo()

If !(GAV->GAV_TIPO $ "2/5") //2=Cirurgico  5=Pre-operatorio
	HS_MsgInf(STR0018, STR0014, STR0015) //"Leito de destino nao e do tipo cirurgico ou pre-operatorio"###"Atencao"###"Admissao Centro Cirurgico"
 	RestArea(aArea)		
	Return(Nil)
Endif

IF GAV->GAV_STATUS != "0" 
	HS_MsgInf(STR0019, STR0014, STR0015) //"O leito informado nao esta vago"###"Atencao"###"Admissao Centro Cirurgico"
 	RestArea(aArea) 	
	Return(Nil)
EndIf
 
//ATENCAO AO FAZER MODIFICACOES AQUI. O LOCK DEVE FICAR SEMPRE APOS TODAS AS VALIDACOES
If !LockByName(xFilial("GAV") + cSetPerg + MV_PAR01 + MV_PAR02, .T., .T., .F.)
	cUsuBloq := HSPVerFiCo("GAV",xFilial("GAV") + cSetPerg + MV_PAR01 + MV_PAR02,.F.) 
	HS_MsgInf(STR0061+" - "+cUsuBloq, STR0014, STR0015) //"Este leito encontra-se bloqueado por outro usuário"###"Atenção"###"Validação do sexo do paciente"
 	RestArea(aArea) 	
	Return(Nil)
Else
    HSPGerFiCo("GAV",xFilial("GAV") + cSetPerg + MV_PAR01 + MV_PAR02)    
EndIf
  
Begin Transaction
	//Atualiza o leito de origem para Reservado
	DbSelectArea("GAV")
	DbSetOrder(1)
	If DbSeek(xFilial("GAV") + cOldSetor + cOldQuarto + cOldLeito )
  		RecLock("GAV", .F.)
		GAV->GAV_RESERV := IIf(cResLeit == "0", SPACE(Len(GAV->GAV_RESERV)),"Y")
		GAV->GAV_OBSERV := IIf(cResLeit == "0", SPACE(Len(GAV->GAV_OBSERV)),STR0020) //"LEITO OCUPADO"
		GAV->GAV_STATUS := IIf(cResLeit == "0", "0" ,"5")   	
	//Caso o Parametro de Reserva leito MV_RESLEIT não esteja ativo  libera o Leito anterior do paciente
	If cResLeit  == "0"
		GAV->GAV_REGATE	:= Space(Len(GAV->GAV_REGATE))
		GAV->GAV_REGGER	:= Space(Len(GAV->GAV_REGGER))
		GAV->GAV_NOME  	:= Space(Len(GAV->GAV_NOME  ))
		GAV->GAV_CODCRM	:= Space(Len(GAV->GAV_CODCRM))
		GAV->GAV_MEDICO	:= Space(Len(GAV->GAV_MEDICO))
		GAV->GAV_DATATE	:= CtoD(" / / ")
		GAV->GAV_HORATE	:= Space(Len(GAV->GAV_HORATE))
	Endif
  		MsUnlock()
	EndIf
   
	HS_GrvMovH(cOldRegAte, cSetPerg, MV_PAR01, MV_PAR02, "0", dDataRef, cHoraRef) /*INTERNACAO NO NOVO LEITO*/

	UnLockByName(xFilial("GAV") + cSetPerg + MV_PAR01 + MV_PAR02, .T., .T., .F.)
    HSPDelFiCo("GAV",xFilial("GAV") + cSetPerg + MV_PAR01 + MV_PAR02) 
  
	GAV->(DbGoTo(nRecNo_Des))
End Transaction  

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±      TRANSFERENCIA                                                      ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION HS_M35TRA(cAlias, nReg, nOpc)
 Local nRecNo_Des := 0
 Local aArea      := GetArea()
 Local cOldQuarto := ""
 Local cOldSetor  := ""
 Local coldTipLoc := ""
 Local cOldLeito  := ""
 Local cOldTipo   := ""
 Local cOldRegate := ""
 Local cOriQuarto := ""
 Local cOriSetor  := ""
 Local cOriLeito  := ""
 Local cNewTipLoc := ""
 Local cBloqUsu   := ""
 Local dDataRef   := dDataBase
 Local cHoraRef   := Time()
 
 Private cStatusGAV := "0" // Var usada na funcao de filtro
 
 cGAVTipo			:= "1/2/4/5/6"  //1=Posto 2=C.Cirurgico  4=U.T.I   5=Pre-Operatorio  6=Pos-Operatorio
 
 IF GAV->GAV_CODLOC != cSetPerg
 	HS_MsgInf(STR0021, STR0014, STR0022) //"So admite Transferencia de pacientes Admitidos no Bloco...Operacao cancelada."###"Atencao"###"Transferencia Centro Cirurgico"
 	Return(Nil)
 EndIf

 If !(GAV->GAV_TIPO $ cGAVTipo)
  HS_MsgInf(STR0023, STR0014, STR0022) //"Transferencia permitida somente para leitos do tipo: C.Cirurgico, U.T.I., Pre-operatorio e pos-operatorio"
  Return(Nil)                                        
 Endif 

 cGcsTipLoc	:= "3/4" // Enfermagem ou C.Cirurgico
 cCirCodLoc	:= cSetPerg

 cOldQuarto := GAV->GAV_QUARTO
 cOldSetor  := GAV->GAV_CODLOC
 cOldLeito  := GAV->GAV_LEITO
 cOldTipo   := GAV->GAV_TIPO
 cOldRegAte := GAV->GAV_REGATE
 DbSelectArea("GCS")
 DbSetOrder(1)//1/CODLOC
 DbSeek(xFilial("GCS") + MV_PAR01) 
 cOldTipLoc := GCS->GCS_TIPLOC
 
 DbSelectArea("GAV")
 DbSetOrder(2)
 If DbSeek(xFilial("GAV") + cOldRegAte + "Y" ) /* Pesquisa o leito original reservado*/
  cOriSetor  := GAV->GAV_CODLOC
  cOriQuarto := GAV->GAV_QUARTO
  cOriLeito  := GAV->GAV_LEITO
 Endif 

 If !Pergunte(cPerg3, .T.)
 	RestArea(aArea)   
 	Return(Nil)
 EndIf

 DbSelectArea("GCS")
 DbSetOrder(1)//1/CODLOC
 DbSeek(xFilial("GCS") + MV_PAR01) 
 cNewTipLoc := GCS->GCS_TIPLOC
 
 DbSelectArea("GAV")
 DbSetOrder(1)
 If !DbSeek(xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03 )
  HS_MsgInf(STR0017 + MV_PAR01, STR0014, STR0022)  //"Leito nao encontrado no setor "###"Atencao"###"Transferencia Centro Cirurgico"]
 	RestArea(aArea)  
 	Return(Nil)
 Endif	
 
 IF GAV->GAV_STATUS != "0" 
  If !Empty(cOriSetor) .And. cOriSetor == MV_Par01 .And. cOriQuarto == MV_Par02 .And. cOriLeito == MV_PAR03
    HS_MsgInf(STR0043, STR0014, STR0022)  //"O leito selecionado refere-se ao leito de origem do paciente. Utilize a funcao 'Saida'"
  	RestArea(aArea)  
  	Return(Nil)
  Else	
  	HS_MsgInf(STR0019, STR0014, STR0022) //"O leito informado nao esta vago"###"Atencao"###"Transferencia Centro Cirurgico"
  	RestArea(aArea)
   Return(Nil)
  Endif 
 EndIf 

 If GAV->GAV_TIPO $ "2/5/6" .And. cOldTipo $ "2/5/6" .And. GAV->GAV_CODLOC <> cOldSetor
		HS_MsgInf(STR0045, STR0014, STR0022) //"Transferencia entre leitos do tipo Pré operatório, Cirurgico ou Pós operatório só é permitida dentro do mesmo setor"###"Atencao"###"Transferencia Centro Cirurgico" 
 	RestArea(aArea)		
  Return(Nil)
 Endif
 
 If cOldTipLoc == cNewTipLoc .And. cOldTipo == "5" .And. GAV->GAV_TIPO <> "2" 
		HS_MsgInf(STR0046, STR0014, STR0022) //"Transferencia dentro de setores Cirurgicos de um leito do tipo Pré operatório só é permitida para um leito do tipo Cirúrgico"###"Atencao"###"Transferencia Centro Cirurgico" 
 	RestArea(aArea)		
  Return(Nil)
 Endif
 
 If GAV->GAV_CODLOC == cOldSetor .And. cOldTipo == "2" .And. !GAV->GAV_TIPO $ "2/6" 
  HS_MsgInf(STR0047, STR0014, STR0022) //"Transferencia no mesmo setor Cirúrgico de um leito do tipo Cirúrgico só é permitida para um leito do tipo Cirúrgico ou Pós operatório"###"Atencao"###"Transferencia Centro Cirurgico" 
 	RestArea(aArea)		
  Return(Nil)
 Endif

 lFilGm1    := .T.

 If !ApMsgYesNo(STR0025) //"Confirma a Transferencia de Leito ?"
 	RestArea(aArea) 
  Return()
 Endif 

 If !(FS_VldData("GB1", 2,xFilial("GB1")+cOldRegAte+cOldSetor+cOldQuarto+cOldLeito+"", "GB1_DATAE", "GB1_HORAE", dDataRef, cHoraRef, STR0057+STR0056) )
 	RestArea(aArea) 
  Return(Nil)
 EndIf
 
 //ATENCAO AO FAZER MODIFICACOES AQUI. O LOCK DEVE FICAR SEMPRE APOS TODAS AS VALIDACOES
 If !LockByName(xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03, .T., .T., .F.)
     cBloqUsu := HSPVerFiCo("GAV",xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03,.F.) 
     HS_MsgInf(STR0061+" - "+cBloqUsu, STR0014, STR0015) //"Este leito encontra-se bloqueado por outro usuário"###"Atenção"###"Validação do sexo do paciente"
 	RestArea(aArea) 	
  Return(Nil)
 Else
     HSPGerFiCo("GAV",xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03)    
 EndIf
 
 nRecNo_Des := RecNo()                 

 HS_LibLCC(cOldSetor, cOldQuarto, cOldLeito, cOldRegAte, dDataRef, cHoraRef)

 If cNewTipLoc <> "4" //so libera o leito original se a movimentacao nao for dentro do CCirurgico
  DbSelectArea("GAV")
  DbSetOrder(2)
  If DbSeek(xFilial("GAV") + cOldRegAte + "Y" ) /* Pesquisa o leito original reservado*/
   HS_LibLCC(GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, cOldRegAte)
  Endif
 EndIf 
 	
	HS_GrvMovH(cOldRegAte, MV_PAR01, MV_PAR02, MV_PAR03, "0", dDataBase, Time() ) /*INTERNACAO NO NOVO LEITO*/
	
	UnLockByName(xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03, .T., .T., .F.)
	HSPDelFiCo("GAV",xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03) 
	
 GAV->(DbGoTo(nRecNo_Des))   
Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±      MOVIMENTACAO DE SAIDA                                              ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function HS_M35SAI(cAlias, nReg, nOpc)
 Local cOriQuarto := ""
 Local cOriSetor  := ""
 Local cOriLeito  := ""
 Local lRet       := .T.
Local aRegEsp  :={}
 Local nRecNo_Des := 0
 Local dDataRef   := dDataBase
 Local cHoraRef   := Time()

 Private cStatusGAV := "0" // Var usada na funcao de filtro
 Private cCC_Quarto := ""
 Private cCC_Setor  := ""
 Private cCC_Leito  := ""
 Private cCC_RegAte := ""
 Private  __cFExAlta := "HS_LibLCC(cCC_Setor, cCC_Quarto, cCC_Leito, cCC_RegAte,,, .T.)" //Utilizada na funcao HS_M30Alt()
Private  cCC_Regger:=""
 
 If GAV->GAV_CODLOC != cSetPerg 
  HS_MsgInf(STR0026, STR0014, STR0027) //"So admite Saida do Setor da Entrada do Modulo ...Operacao cancelada."###"Atencao"###"Saida Centro Cirurgico"
  Return(Nil)
 EndIf   

 If !(GAV->GAV_TIPO $ "2/5/6")
  Hs_MsgInf(STR0028, STR0014, STR0027) //"Saida nao permitida para leitos diferentes de Pre-opera´torio, c.cirurgico e pos-operatorio"###"Atencao"###"Saida Centro Cirurgico"
  Return(Ni)
 Endif 
 
 IF !ApMsgYesNo(STR0029 + Alltrim(GAV->GAV_NOME)) //"Confirma a Saida do Paciente? "
  Return()
 Endif
  
 cCC_RegAte := GAV->GAV_REGATE  //RegAte, Setor, Quarto e Leito que esta no CCirurgico
 cCC_Setor  := GAV->GAV_CODLOC 
 cCC_Quarto := GAV->GAV_QUARTO
 cCC_Leito  := GAV->GAV_LEITO
cCC_Regger  := GAV->GAV_REGGER
 
 if !(FS_VldData("GB1", 2,xFilial("GB1")+cCC_RegAte+cCC_Setor+cCC_Quarto+cCC_Leito+"", "GB1_DATAE", "GB1_HORAE", dDataRef, cHoraRef, STR0058+STR0056) )
  Return(Nil)
 EndIf
 
 DbSelectArea("GAV")
 DbSetOrder(2)
 If (lOri := DbSeek(xFilial("GAV") + cCC_RegAte + "Y" )) /* Pesquisa o leito original reservado*/
  Begin Transaction

   cOriQuarto := GAV->GAV_QUARTO
   cOriSetor  := GAV->GAV_CODLOC
   cOriLeito  := GAV->GAV_LEITO
   RecLock("GAV", .F.) /* DESMARCA A RESERVA DO LEITO ORIGINAL PARA O RETORNO DO PACIENTE*/
    GAV->GAV_RESERV  := " "
    GAV->GAV_STATUS  := "1"
    GAV->GAV_OBSERV  := Space(Len(GAV->GAV_OBSERV))
   MsUnlock()              
   
   nRecNo_Des := RecNo()
   
   HS_LibLCC(cCC_Setor, cCC_Quarto, cCC_Leito, cCC_RegAte, dDataRef, cHoraRef)
 
   GAV->(DbSeek(xFilial("GAV") + cOriSetor + cOriQuarto + cOriLeito ))
   
   GAV->(DbGoTo(nRecNo_Des))
	HS_GrvMovH(cCC_RegAte, cOriSetor, cOriQuarto, cOriLeito, "0", dDataRef, cHoraRef ) /*INTERNACAO NO NOVO LEITO*/ //grava no recno posicionado

  End Transaction 
  GAV->(DbGoTo(nRecNo_Des))
ElseIf !lOri .AND.	HS_ExisDic({{"C", "GCS_LSTESP"}}, .F.)///Se o setor for de lista de espera
	DbSelectArea("GCS")
	DbSetOrder(1)
	Dbseek(xFilial("GCS")+cCC_Setor)  //GCS_FILIAL+GCS_CODLOC
	If GCS->GCS_LSTESP =="1"   // Verificando se O setor atende a Lista de Espera
		aRegEsp:=Fs_listEsp(cCC_Regger,cAlias,nReg,nOpc,cCC_RegAte) // Verifica se Existe Paciente cadastrado em algum setor de Lista de Espera //
		If aRegEsp[1] // se retornou algum paciente Realiza o Processo de Alocação de Setor, Quarto e Leito ao Paciente
			DbSelectArea("GAV")
			DbSetOrder(5)
			If (lOri := DbSeek(xFilial("GAV") + cCC_Regger )) /* Pesquisa o leito original reservado*/
				Begin Transaction
				nRecNo_Des := RecNo()
				HS_LibLCC(cCC_Setor, cCC_Quarto, cCC_Leito, cCC_RegAte, dDataRef, cHoraRef) // Libera o Setor Centro Cirurgico
				GAV->(DbGoTo(nRecNo_Des))
				HS_GrvMovH(cCC_RegAte, aRegEsp[2], aRegEsp[3], aRegEsp[4], "0", dDataRef, cHoraRef ) /*INTERNACAO no Setor cadastrado da Lista de Espera*/
				End Transaction
				GAV->(DbGoTo(nRecNo_Des))
				
			Endif
		Else
			lRet := HS_M30ALT("GAV", 0, 2,, .T., cCC_RegAte, .F.)
			
			GAV->(DbGoTop())
		Endif
		If  HS_CountTB("GT6", "GT6_REGGER = '" + cCC_Regger + "'") > 0  //Realiza a exclusão do Paciente na Fila de Espera		
			HS_ExclEs(cCC_Regger)
		Endif
	
	ElseIf GCS->GCS_LSTESP =="0" .or. Empty(GCS->GCS_LSTESP)
		lRet := HS_M30ALT("GAV", 0, 2,, .T., cCC_RegAte, .F.)
		GAV->(DbGoTop())
	Endif
		
	
Elseif lRet := HS_M30ALT("GAV", 0, 2,, .T., cCC_RegAte, .F.)
	
  GAV->(DbGoTop())
 Endif
                  
 //FS_RefrBrw()  
Return(Nil)

/******************************************************************************************************************/
Function HS_M35REn(cAlias, nReg, nOpc)
 Local nOpcA   := 0 , nGDOpc  := GD_INSERT + GD_UPDATE + GD_DELETE
 Local aCpoEnc := {	"GAV_REGATE","GAV_NOME","GAV_QUARTO","GAV_LEITO"}
 Local aCGDZ	:= {}, aHGDZ := {}, nUGDZ := 0, oDlgREn, oGav , cOldArq := ""
 Local cAtend := " "
 Local lAchou := .T.
 Local nCont := 0
 
 Private nGdzCodcrm := 0, nGdzNommed := 0, nGdzCodato := 0, nGdzDesato := 0,nGdzCtrole:=0, oGDZ

AjustaSX1()

If Empty(GAV->GAV_REGATE)
 
     Pergunte("HM35C", .T.)
      cAtend := alltrim(MV_PAR01)
	            
     If !Empty(cAtend)
	     DbSelectArea("GAV")
	     GAV->(DbSetOrder(2))
		  If GAV->(DbSeek(xFilial("GAV") + cAtend))
			  lAchou := .T.
			Else
				lAchou := .F.		   
			Endif  
	  Endif	
Endif

If  lAchou  
 RegToMemory("GAV", .F.)
 
 HS_BDados("GDZ", @aHGDZ, @aCGDZ, @nUGDZ, 1, M->GAV_REGATE, "'" + M->GAV_REGATE + "' == GDZ->GDZ_REGATE")
 
 nGdzCodcrm := aScan(aHGDZ, {| aVet | aVet[2] == "GDZ_CODCRM"})
 nGdzNommed := aScan(aHGDZ, {| aVet | aVet[2] == "GDZ_NOMMED"})
 nGdzCodato := aScan(aHGDZ, {| aVet | aVet[2] == "GDZ_CODATO"})
 nGdzDesato := aScan(aHGDZ, {| aVet | aVet[2] == "GDZ_DESATO"})
 
 If GDZ->(FieldPos("GDZ_CTROLE")) > 0 
 	nGdzCtrole := aScan(aHGDZ, {| aVet | aVet[2] == "GDZ_CTROLE"})
 Endif  
 If Empty(aCGDZ[1, nGdzCtrole])
  aCGDZ[1, nGdzCtrole] := Soma1(aCGDZ[1, nGdzCtrole], Len(aCGDZ[1, nGdzCtrole]))
 EndIf    
 If Len(aCGDZ) <= 1
  DbSelectArea("GMJ")//RESERVA CIRURGICA
  DbSetOrder(5)
  If DbSeek(xFilial("GMJ") + GAV->GAV_REGGER ) //GAV= RELACIONA ATO MEDICO PACIENTE
   DO WHILE !Eof() .AND. GMJ->GMJ_FILIAL == xFilial("GMJ") .AND. GMJ->GMJ_REGGER == GAV->GAV_REGGER

     cOldArq := Alias()
     DbSelectArea("GE9") //AGENDA CIRURGICA MEDICO
     DbSetOrder(1)
     If DbSeek(xFilial("GE9") + GMJ->GMJ_CODAGE )
      DO WHILE !Eof() .AND. GE9->GE9_FILIAL == xFilial("GE9") .AND. GE9->GE9_CODAGE == GMJ->GMJ_CODAGE
      	If Empty(aCGDZ[1][1])
      		aCGDZ[1][1]     := GE9->GE9_CODCRM
			aCGDZ[1][2]     := Posicione("SRA",11,xFilial("SRA")+GE9->GE9_CODCRM,"RA_NOME")
			aCGDZ[1][3]     := GE9->GE9_TIPATM
			aCGDZ[1][4]     := Posicione("GMC",1,xFilial("GMC")+GE9->GE9_TIPATM,"GMC_DESATO")
			aCGDZ[1][5]     := Date()
			aCGDZ[1][6]     := TIME()
			aCGDZ[1][7]     := CTOD("  /  /    ")
			aCGDZ[1][8]     := "     "			
			aCGDZ[1][9]     := Soma1(aCGDZ[1, nGdzCtrole], Len(aCGDZ[1, nGdzCtrole]))       
			aCGDZ[1][10]   := .F.
		Else
	       	nCONT := nCONT +1
			AADD(aCGDZ,{GE9->GE9_CODCRM,;
				Posicione("SRA",11,xFilial("SRA")+GE9->GE9_CODCRM,"RA_NOME"),;
			 	GE9->GE9_TIPATM,;
			  	Posicione("GMC",1,xFilial("GMC")+GE9->GE9_TIPATM,"GMC_DESATO"),;
			   	Date(),;
			    TIME(),; 
			    Date(),;//Sugestao de database, porque o registro ainda não existe na GDZ 
			    "     ",;
			    Soma1(aCGDZ[nCont, nGdzCtrole], Len(aCGDZ[1, nGdzCtrole])),;
			    .f. } )
		Endif
      	DbSkip()
      EndDo
     EndIf
     DbSelectArea(cOldArq)
    
    DbSkip()
   EndDo
  EndIf
 EndIf
 
 DbSelectArea("GAV")
 DEFINE MSDIALOG oDlgREn TITLE cCadastro From 000, 000 To 340, 640	PIXEL of oMainWnd

  oGav := MsMGet():New("GAV", nReg, nOpc,,,, aCpoEnc, {015, 001, 080, 320},, 2,,,, oDlgREn,, .F.,,,.T.)
  oGav:oBox:Align := CONTROL_ALIGN_TOP
  
  oGDZ := MsNewGetDados():New(085, 000, 180, 320, nGDOpc,,,"+GDZ_CTROLE",,,,,,, oDlgREn, aHGDZ, aCGDZ)
  oGdz:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT  

 ACTIVATE MSDIALOG oDlgREn CENTERED ON INIT EnchoiceBar(oDlgREn, {|| nOpcA := 1, IIf(oGDZ:TudoOk(), oDlgREn:End(), nOpcA := 0)}, ;
                                                                 {|| nOpcA := 0, oDlgREn:End()})

 If nOpcA == 1
  Begin Transaction 
   FS_GrvREn(nUGdz)
  End Transaction
  While __lSx8
   ConfirmSx8() 
  End
 Else
  While __lSx8
   RollBackSx8() 
  End
 EndIf
Else
		HS_MsgInf(STR0067,STR0068 ,STR0069 )//"Atendimento selecionado não esta vinculado a nenhum quarto/leito."   #"Atenção"    ##"Validação" 	
Endif

Return(Nil)

/*****************************************************************************************************************/
Static Function FS_GrvREn(nUGdz)
 Local nItem := 0, cAliasOld := Alias(), lAchou := .F.
 Local   nOrdem :=0
 Local   cchave :=""
 
 For nItem := 1 To Len(oGdz:aCols)
 
		If !Empty(oGDZ:aCols[nItem, nGdzCtrole])
		nOrdem:=2
		cChave:=M->GAV_REGATE+ oGDZ:aCols[nItem, nGdzCodCrm] + oGDZ:aCols[nItem, nGdzCodato]+oGDZ:aCols[nItem, nGdzCtrole]
 	Else 
		nOrdem:=1
		cChave:=M->GAV_REGATE+ oGDZ:aCols[nItem, nGdzCodCrm] + oGDZ:aCols[nItem, nGdzCodato] 								
 	EndIf
  DbSelectArea("GDZ")
	GDZ->(DbSetOrder(nOrdem))
	lAchou := DbSeek(xFilial("GDZ") + cChave )
  If oGdz:aCols[nItem, nUGdz + 1] /* exclusao */
   If lAchou
    RecLock("GDZ", .F., .T.)
     DbDelete()
    MsUnlock()
    WriteSx2("GDZ")
   EndIf 
  Else                             
   RecLock("GDZ", !lAchou)
    HS_GRVCPO("GDZ", oGdz:aCols, oGdz:aHeader, nItem)
    GDZ->GDZ_FILIAL := xFilial("GDZ")
    GDZ->GDZ_REGATE := M->GAV_REGATE
    GDZ->GDZ_LOGARQ := HS_LogArq()
   MsUnlock()                  
  EndIf 
 Next
 
 DbSelectArea(cAliasOld)
Return(Nil)
/******************************************************************************************************************/


Function HS_VldM35()
 Local lRet := .T.
 
 If ReadVar() == "M->GDZ_CODCRM"
 If !(lRet := HS_SeekRet("SRA", "M->GDZ_CODCRM", 11, .F., "GDZ_NOMMED", "RA_NOME"))
   HS_MsgInf(STR0032, STR0014,STR0001) //###Profissional não encontrado","Atencao"
  EndIf
 ElseIf ReadVar() == "M->GDZ_CODATO"
  If !(lRet := HS_SeekRet("GMC", "M->GDZ_CODATO", 1, .F., "GDZ_DESATO", "GMC_DESATO"))
   HS_MsgInf(STR0035, STR0014,STR0001) //"Atencao"###"Ato medico não encontrado","Atencao" //"MOVIMENTACAO DO CENTRO CIRURGICO"
  EndIf
 EndIf
 
Return(lRet)                          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	   ³HS_M35DES ³ Autor ³Jose Orfeu             ³ Data ³12/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ LANCAMENTO DAS DESPESAS                             					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Alias do Arquivo                       									  ³±±
±±³          ³ ExpN02 - Nr. do registro                        									  ³±±
±±³          ³ ExpN03 - Opcao Selecionada (Gerar Fatura ou Excluir)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno 	 ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSPAHM35 											                                    	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function HS_M35DES(cAlias, nReg, nOpc)   //DESPESAS
 Local aArea	:= GetArea()

 DbSelectArea("GCY")
 DbSetOrder(1)
 If !dbSeek(xFilial("GCY") + GAV->GAV_REGATE)
  HS_MsgInf(STR0036, STR0014,STR0044) //"Registro de atendimento não encontrado. Chame o suporte."###"Atencao" //"LANCAMENTO DAS DESPESAS"
 Else
 	HS_CtrlM24({GCY->GCY_ATENDI, GCY->GCY_REGATE, "P", 7, cGcsCodLoc, ""})
 EndIf

 RestArea(aArea)
Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±      ATIVA FILTRO DO BROWSE                                             ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_FilM35(cPerg, lSetFilter)
 Local lRet     := .F.
 Local oObjMBrw := ""

 Default lSetFilter := .T.
 
 oObjMBrw           := IIf(lSetFilter, GetObjBrow(), Nil) 

 DbSelectArea("GAV")
 DbSetOrder(1)
 DbGoTop()
 
 If (lRet := Pergunte(cPerg, .T.))
  cSetPerg   := MV_PAR01
  cGcsCodLoc := MV_PAR01
  cGcsTipLoc := "4"
  cFilM35    := "GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV_STATUS = '1'"
  If !EMPTY(MV_PAR02)
   cFilM35 := cFilM35 + " AND GAV_DATATE = '" + DTOS(MV_PAR02) + "'"
  EndIf
  If !EMPTY(MV_PAR03)
   cFilM35 := cFilM35 + " AND GAV_CODCRM = '" + MV_PAR03 + "'"
  EndIf
  If !EMPTY(MV_PAR04)
   cFilM35 := cFilM35 + " AND GAV_REGGER = '" + MV_PAR04 + "'"
  EndIf
  
  If lSetFilter
   SetMBTopFilter("GAV", cFilM35)
   oObjMBrw:GoTop()
   oObjMBrw:Refresh()
  EndIf

 EndIf
Return(lRet)

/******************************************************************************************************************/
//Antiga validacao do dicionario HS_VALM35(MV_PAR01,'3','Transferencia de leito')
FUNCTION HS_VALM35(cParam01, cSector, cFrase)
 Local lRet  := .F.
 Local aArea := GetArea()
 
 IF HS_VLDCSET(cParam01, "", cSector, cFrase)
  cGcsCodLoc := MV_PAR01
  lRet       := .T.
 EndIf
 
 RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VldSM35ºAutor  ³Fabricio E. da Costaº Data ³  25/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Valida o setor do grupo de perguntas do processo de         º±± 
±±º          ³transferencia no posto de enfermagem. Apaga o conteudo dos  º±±
±±º          ³dos campos de pergunta para tentar evitar um problema       º±±
±±º          ³tecnologico no browse de consulta padrao                    º±±
±±º          ³Parametros:                                                 º±±
±±º          ³cValor                                                      º±±
±±º          ³ Conteudo a ser validado                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HSPAHM35                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_VldSM35(cValor)
 Local lOk := .F.
 Local aArea := GetArea()

	DbSelectArea("GAV")
	DbSetOrder(1)
 IF lOk := HS_VLDCSET(cValor, "", "3", "Transferência de Leito")//Verifica se existe o Setor do tipo 3 (Enfermagem)
 	cGcsCodLoc := MV_PAR01
	EndIf	
	MV_PAR02 := Space(Len(MV_PAR02))
	MV_PAR03 := Space(Len(MV_PAR03)) 	
	RestArea(aArea)
	
Return lOk

/******************************************************************************************************************/
Function HS_M35LEG()
 BrwLegenda(STR0009, STR0038, {{"BR_VERDE"   , STR0039}, ; //"Legenda"###"Centro Cirurgico"###"Ambulatorio"
                                            {"BR_AMARELO" , STR0038}, ; //"Centro Cirurgico"
                              						        {"BR_AZUL"    , STR0040}, ; //"Postos de Enfermagem"
                              						        {"BR_VERMELHO", STR0041}, ; //"U.T.I."
                              						        {"BR_BRANCO"  , STR0048}, ; //"Espera"
                  						               	    {"BR_CINZA"   , STR0042}})  //"Bercario"

Return(Nil)                      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±      CHAMA ROTINA PARA IMPRIMIR AS FICHAS DE ATENDIMENTO                ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_RelM35(cAlias, nReg, nOpc)  
 Local aArea := GetArea()

 GDN->(dbSetOrder(1))
 If GDN->(DbSeek(xFilial("GDN") + GAV->GAV_CODLOC))
  HSPAHP44(.F.,GAV->GAV_CODLOC, {{"GCY", 1, GAV->GAV_REGATE}} ) 
 EndIf 
 
 RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±      LIBERA LEITO DO CENTRO CIRURGICO                                   ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_LibLCC(cSetor, cQuarto, cLeito, cRegAte, dDataRef, cHoraRef, lAtuGCY)
 Local   aArea := GetArea()
 Default dDataRef := dDataBase
 Default cHoraRef := Time()
 Default lAtuGCY  := .F.
 
 DbSelectArea("GAV")
 DbSetOrder(1)  //GAV_FILIAL+GAV_CODLOC+GAV_QUARTO+GAV_LEITO
 DbSeek(xFilial("GAV") + cSetor + cQuarto + cLeito)
 
 HS_GrvMovH(cRegAte, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "1", dDataRef, cHoraRef,,,,,,,,lAtuGCY)
 HS_GrvMovH(cRegAte, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "2", dDataRef, cHoraRef,,,,,,,,lAtuGCY)
 HS_GrvMovH(""     , GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "3", dDataRef, cHoraRef,,,,,,,,lAtuGCY)
 HS_GrvMovH(""     , GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "4", dDataRef, cHoraRef,,,,,,,,.F. )
 HS_GrvMovH(""     , GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "5", dDataRef, cHoraRef,,,,,,,,.F. )
 
 RestArea(aArea)
Return(.T.)

//Static Function FS_RefrBrw()
// Local  oObjMBrw := GetObjBrow()
//
// oObjMBrw:Refresh()
//
//Return()

Function HS_PacM35(cAlias, nReg, nOpc)

 HS_PosSX1({{"HSM35A", "01", GAV->GAV_REGGER}})

 If !Pergunte("HSM35A", .T.)
  Return()	
 EndIf
 
 DbSelectArea("GBH")              
 DbSetOrder(1) // GBH_FILIAL + GBH_CODPAC
 If DbSeek(xFilial("GBH") + MV_PAR01)
  HS_A58("GBH", GBH->(RecNo()), nOpc)          
 Else
  HS_MsgInf(STR0050, STR0051, STR0052) //"Prontuário não encontrado"###"Atenção"###"Cadastro Paciente"
 EndIf 

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_TriM35 ºAutor  ³Daniel Peixoto      º Data ³  22/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Evolução                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_TriM35(cAliasM35, nRegM35, nOpcM35)
 Local aArea := GetArea()
 
 Private __cMa7Aces := "E" // Elaboração
 Private nQtdAnm    := 0   // Quantidade de historico de anamnese
 Private nVisAnm    := 0   // 0=Visualiza anamnese de outro profissional
 Private cLocCon    := ""  //GCY->GCY_CODLOC
 Private aCodUsr    := {}  //HS_VldDAnm(.F.)
 
 DBSelectArea("GCY")
 DbSetOrder(1)//REGATE
 DbSeek(xFilial("GCY") + GAV->GAV_REGATE)
 
 cLocCon    := GCY->GCY_CODLOC
 aCodUsr    := HS_VldDAnm(.F.)
 
 If Len(aCodUsr) > 2 
  If aCodUsr[3]
   __cMa7Aces := "C"
  EndIf
 EndIf
  
 If Empty(aCodUsr[2])
  aCodUsr[1] := .T.
  aCodUsr[2] := IIf(Empty(GCY->GCY_CRMANM), GCY->GCY_CODCRM, GCY->GCY_CRMANM) 
  If Len(aCodUsr) > 2 
   aCodUsr[3]:= .F.
  EndIf
 EndIf             

If MV_PAR01 <> cGcsCodLoc
	MV_PAR01 := cGcsCodLoc
EndIf

HS_MntMA7("GCY", GCY->(RecNo()), 3, ,GAV->GAV_RESERV) 
 
 RestArea(aArea)
Return(Nil)   

Static Function FS_VldData(cAlias, nInd, cChave, cCpoData, cCpoHora, dData, cHora, cMsg)
 Local lRet    := .T.
 Local aArea   := getArea()
 Local cPref   := cAlias + "->"
 
 Default nInd := 1
  
 DbSelectArea(cAlias)
 DbSetOrder(nInd)
 if DbSeek(cChave)
  if dData < &(cPref+cCpoData) 
   Hs_MsgInf(cMsg, STR0051, STR0053)
   lRet := .F.
  ElseIf dData = &(cPref+cCpoData)
   If cHora < &(cPref+cCpoHora)
    Hs_MsgInf(cMsg, STR0051, STR0053)
    lRet := .F.
   EndIf   
  EndIf                
  DbSkip()
 Else 
  lRet := .F.
 EndIf 
 
 RestArea(aArea) 
return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |Fs_listEsp  ºAutor  ³Microsiga           º Data ³  01/04/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a Busca da lista de Espera para Pacientes           º±±
±±º          ³Admitidos diretamente no Centro Cirurgico                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function  Fs_listEsp(cGavRegger,cAlias,nReg, nOpc,cCC_RegAte)
Local aArea   := getArea()
Local lRet:= .F.
Local lRetVal:= .T.


Private  cCC_SetEsp:=""
Private  cCC_QuarEsp:=""
Private  cCC_LeiEsp:=""

DbSelectArea("GT6")
GT6->(DbSetOrder(2))
If 	GT6->(DbSeek(xFilial("GT6") + PADR(cGavRegger,Len(GT6->GT6_REGGER))))
	cCC_SetEsp  := GT6->GT6_CODLOC
	
	If  !Empty(GT6->GT6_QUARTO) .and. !Empty(GT6->GT6_LEITO)  // Se oquarto e o  Leito  estiver na Lista de espera
		DbSelectArea("GAV")
		DbSetOrder(1)
		
		If !DbSeek(xFilial("GAV") + cCC_SetEsp + GT6->GT6_QUARTO + GT6->GT6_LEITO)
			HS_MsgInf(STR0017 + cSetPerg, STR0014, STR0015) //"Leito nao encontrado no setor "###"Atencao"###"Admissao Centro Cirurgico"
			lRetVal:= .F.
		Endif
		
		IF GAV->GAV_STATUS != "0"
			HS_MsgInf(STR0066, STR0014, STR0015) //"O leito informado nao esta vago"###"Atencao"###"Admissao Centro Cirurgico"
			lRetVal:= .F.
		EndIf
	Else
			lRetVal:= .F.	
	Endif
	
	If lRetVal  // Se o Leito/Quarto estiver  atribuição para realizar o Ingresso do Paciente ao Leito
		cCC_QuarEsp := GT6->GT6_QUARTO
		cCC_LeiEsp  := GT6->GT6_LEITO
		lRet:= .T.
		
	ElseIf Empty(GT6->GT6_QUARTO) .or. Empty(GT6->GT6_LEITO) .or. !lRetVal   // Se o Leito/Quarto não estiver na Lista Ex: Somente o Setor
		
		DbSelectArea("GCY")
		DbSetOrder(1)
		If !dbSeek(xFilial("GCY") + cCC_RegAte)
			HS_MsgInf(STR0036, STR0014,STR0044) //"Registro de atendimento não encontrado. Chame o suporte."###"Atencao" //"LANCAMENTO DAS DESPESAS"
		Else
			HS_CtrlM24({GCY->GCY_ATENDI, GCY->GCY_REGATE, "P", 4, cCC_SetEsp, ""})// Exibe a tela do M24 para que seja informado o Quarto e o Leito Paciente
			If  !Empty(cCC_QuarEsp) .and. !Empty(cCC_LeiEsp) // Se retorna o Quarto e Leito no M24
				lRet:= .T.
			Else
				lRet:= .F.
			EndIf
		Endif
		
		
		
	Endif
	
Endif

RestArea(aArea)

Return({lRet,cCC_SetEsp,cCC_QuarEsp,cCC_LeiEsp})




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 10/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local aRotRel := {{OemtoAnsi(STR0008), "HS_RELM35", 0, 2, 0, nil},; //"Docs/Relat."
                   {OemtoAnsi(STR0065), 'HSPRQUES("GFK", "GFK_CDANAM", "","",GAV->GAV_REGATE,,,GAV->GAV_CODLOC)', 0, 02}} //"Anamnese
Local aRotina :=	{{OemtoAnsi(STR0002), "axPesqui" , 0, 1, 0, nil},; //"Pesquisar"
                     {OemtoAnsi(STR0003), "HS_M35ADM", 0, 4, 0, nil},; //"Admissao"
                     {OemtoAnsi(STR0004), "HS_M35SAI", 0, 4, 0, nil},; //"Saida"
                     {OemtoAnsi(STR0005), "HS_M35TRA", 0, 4, 0, nil},; //"Transferencia"
                     {OemtoAnsi(STR0006), "HS_M35REN", 0, 2, 0, nil},; //"Reg.Entrada"
                     {OemtoAnsi(STR0007), "HS_M35DES", 0, 4, 0, nil},; //"Despesas"
                     {OemtoAnsi(STR0008),  aRotRel, 0, 2, 0, nil},; //"Docs/Relat."
                     {OemtoAnsi(STR0049), "HS_PACM35", 0, 4, 0, nil},; //"Paciente"
					 {OemtoAnsi(STR0059), "HS_TriM35", 0, 4, 0, nil},; //"Evolução"
                     {OemtoAnsi(STR0009), "HS_M35LEG", 0, 1, 0, nil},;  //"Legenda"
                     {OemtoAnsi(STR0063), "HSPAHM08(GAV->GAV_REGATE,GAV->GAV_RESERV,GAV->GAV_CODLOC)", 19, 02}}// "Pedido de Exames"					                     
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Microsiga           º Data ³  22/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Identificar o codigo do atendimento                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()
Local aArea		:= GetArea()
Local aRegs	:= {}
Local cPerg		:= "HM35C     "

AADD(aRegs,{cPerg,"01","Atendimento? ","¿Atencion? ","Servicing?    ","MV_CH0","C",06,00,00,"G","","MV_PAR01       ","               ","               ","               ","001                                                         ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GCY","N","   ","          ","                                        ","      "})

PlsVldPerg(aRegs)

RestArea(aArea)
Return()
