#include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CFATA00A  �Autor  �Microsiga           � Data �  07/17/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Faturamento do pedido de vendas                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
Criar Parametros:

Vari�vel:        CA_SERNFAU
Descri��o:       Serie da nota fiscal para faturamento automatico. 
Exemplo:         1

Vari�vel:        CA_SERNFFX
Descri��o:       Serie da nota fiscal para faturamento em armazem fechado.
Exemplo:         2

*/
User Function CFATA00A(cPed)
Local lRet 		:= .F.
// Local cTransp 	:= ""

Private cSemaforo	:= ""
                                      		
DbSelectArea("SC5")
SC5->( DbSetOrder(1) ) // C5_FILIAL+C5_NUM
If SC5->(DbSeek(xFilial("SC5")+cPed))

	DbSelectArea("SC6")            
	SC6->( DbSetOrder(1) ) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	If SC6->( DbSeek(xFilial("SC6")+cPed ) )
 
 		DbSelectArea("SC9")
		SC9->( DbSetOrder(1) ) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		If SC9->( DbSeek(xFilial("SC9")+cPed ) )

            // If !U_ProcTransp()
				cSemaforo := "CFATA00A"+xFilial('SC5') 
				While !LockByName(cSemaforo,.F., .F., .T.)
					Sleep(500)
				EndDo
					lRet := SF_CA00A()
				UnLockByName(cSemaforo,.F., .F., .T.)
			// EndIf
			
		EndIf
	EndIf
EndIf

Return lRet

Static Function SF_CA00A(aFatProp)
Local aArea     := GetArea()
Local aLibera   := {}
Local aBloqueio := {{"","","","","","","",""}}
Local aNotas    := {}
Local nItemNf   := 0
Local i         := 0
Local cSerie    := "" 
Local lContinua := .T.
Local lCond9  	:= GetMV("MV_DATAINF",,.F.)
Local cFunName  := FunName()
Local lTxMoeda  := .F.
Local nReg      := SC5->(Recno())

// Default aFatProp  := u_GetFatProp()
// //If ( lContinua := aFatProp[3] <> Nil .and. aFatProp[3] .and. aFatProp[4] <> Nil .and. aFatProp[4] ) 
// lContinua := aFatProp[3] <> Nil .and. aFatProp[3] .and. aFatProp[4] <> Nil .and. aFatProp[4]

if IsInCallStack("U_FATPVDF") .or. IsInCallStack("U_FATPVMAT")
	lContinua := .T.
endif

if lContinua
   cSerie := "1" // aFatProp[2]
   
   lCond9   := IIf(ValType(lCond9)<>"L",.F.,lCond9)
   
   //������������������������������������������������������������������������Ŀ
   //�Retorna o SetFunName que iniciou a rotina                               �
   //��������������������������������������������������������������������������
   
   SetFunName("MATA461")
   
   If ( ExistBlock("M410PVNF") )
   	lContinua := ExecBlock("M410PVNF",.f.,.f.,nReg)
   EndIf
   
   If lContinua
       // aLibera ::={ <C9_PEDIDO>, <C9_ITEM>, <C9_SEQUEN>, <C9_QTDLIB>, <C9_PRCVEN>, <C9_PRODUTO>, <F4_ISS=="S">, <SC9->(RecNo())>,;
   	//              <SC5->(RecNo())>, <SC6->(RecNo())>, <SE4->(RecNo())>, <SB1->(RecNo())>, <SB2->(RecNo())>, <SF4->(RecNo())>,
       //              <C9_LOCAL>, 0, <C9_QTDLIB2> }
       // aBloqueio ::= { <C9_PEDIDO>, <C9_ITEM>, <C9_SEQUEN>, <C9_PRODUTO>, <C9_QTDLIB>, <C9_BLCRED>, <C9_BLEST>, <C9_BLWMS> }
   
   	U_LoadNFS(@aLibera,@aBloqueio)
   
   	If Empty(aBloqueio) .and.  !Empty(aLibera)
   		nItemNf  := A460NumIt(cSerie)
   		//���������������������������������������������������������������Ŀ
   		//� Define variaveis de parametrizacao de lancamentos             �
   		//�����������������������������������������������������������������
   		//���������������������������������������������������������������Ŀ
   		//� mv_par01 Mostra Lan?.Contab ?  Sim/Nao                        �
   		//� mv_par02 Aglut. Lan?amentos ?  Sim/Nao                        �
   		//� mv_par03 Lan?.Contab.On-Line?  Sim/Nao                        �
   		//� mv_par04 Contb.Custo On-Line?  Sim/Nao                        �
   		//� mv_par05 Reaj. na mesma N.F.?  Sim/Nao                        �
   		//� mv_par06 Taxa deflacao ICMS ?  Numerico                       �
   		//� mv_par07 Metodo calc.acr.fin?  Taxa defl/Dif.lista/% Acrs.ped �
   		//� mv_par08 Arred.prc unit vist?  Sempre/Nunca/Consumid.final    �
   		//� mv_par09 Agreg. liberac. de ?  Caracter                       �
   		//� mv_par10 Agreg. liberac. ate?  Caracter                       �
   		//� mv_par11 Aglut.Ped. Iguais  ?  Sim/Nao                        �
   		//� mv_par12 Valor Minimo p/fatu?                                 �
   		//� mv_par13 Transportadora de  ?                                 �
   		//� mv_par14 Transportadora ate ?                                 �
   		//� mv_par15 Atualiza Cli.X Prod?                                 �
   		//� mv_par16 Emitir             ?  Nota / Cupom Fiscal            �
   		//�����������������������������������������������������������������		
   
//   		If ( Pergunte("MT460A",.F.) ) // tirei, miguel
   			AAdd(aNotas,{})			
   		    For i := 1 To Len(aLibera)
   		    	If Len(aNotas[Len(aNotas)]) >= nItemNf
   		    		AAdd(aNotas,{})
   		    	EndIf
   		    	AAdd(aNotas[Len(aNotas)], aClone(aLibera[i]))
   			Next         
   
   			If ExistBlock("M410ALDT")			
                dDataBase := If(ValType(dDataPE := ExecBlock("M410ALDT", .F., .F.))=='D', dDataPE , dDataBase) 
            Endif
   
   			For i := 1 To Len(aNotas)
   				// Verifica se bloqueia faturamento quando o 1o vencto < emissao da NF na cond.pgto tipo 9 (T = Bloqueia , F = Fatura)
   				// Bloqueia faturamento se a moeda nao estiver cadastrada
   				// Neste momento o SC5 esta posicionado no item que ir� gerar a nota fiscal.
   				If !(( lCond9 .And. SC5->C5_DATA1 < dDataBase .And. !Empty(SC5->C5_DATA1) );
   						.Or. ( xMoeda( 1, SC5->C5_MOEDA, 1, dDataBase, TamSX3("M2_MOEDA2")[2] ) = 0 ))
   					//MaPvlNfs(aNotas[i],cSerie,MV_PAR01==1,MV_PAR02==1,MV_PAR03==1,MV_PAR04==1,MV_PAR05==1,MV_PAR07,MV_PAR08,MV_PAR15==1,MV_PAR16==2)
/* 
					cSemaforo := "CFATA00A"+cFilant+cSerie
					While !LockByName(cSemaforo,.F., .F., .T.)
						Sleep(500)
					End
 */
						MaPvlNfs(aNotas[i],cSerie,.F.,.F.,.F.,.F.,.F.,3,3,.F.,.F.)
						SX6->(MsRUnLock()) // destravar X6 para liberar faturamento, alteracao realizada no dia 25/03. ANDREZ�O.
/*                      
					UnLockByName(cSemaforo,.F., .F., .T.)       
 */
   				Else
   					If ( xMoeda( 1, SC5->C5_MOEDA, 1, dDataBase ) = 0 )
   						lTxMoeda := .T.
   					EndIf
   				EndIf
   
   				//���������������������������������������������������������������������������������������Ŀ
   				//�P.E . para exibir mensagem com motivo de n�o faturar de acordo com parametro MV_DATAINF�
   				//�����������������������������������������������������������������������������������������
   				If (lCond9 .And. SC5->C5_DATA1 < dDataBase .And. !Empty(SC5->C5_DATA1) ) .And. ExistBlock( "M461DINF" ) 
   					ExecBlock( "M461DINF", .f., .f. ) 
   				EndIf
   			Next
   		//EndIf
   	Else
   		lContinua := .F.
	    Alert('Um ou mais itens do pedido de vendas ' + SC5->C5_NUM + ' n�o foram liberados. Ref Ped Site: ' + SC5->C5_NUMPVIM + '.','E')
   	EndIf
   EndIf                                                                       
   
   //������������������������������������������������������������������������Ŀ
   //�Retorna o SetFunName que iniciou a rotina                               �
   //��������������������������������������������������������������������������
   SetFunName(cFunName)
   	
   //Mensagem para o usu�rio em caso de existirem notas com datas onde n�o foram encontrados valores de moeda cadastrados
   If lTxMoeda
   	  lContinua := .F.
	  Alert("O pedido " + SC5->C5_NUM + " n�o foi gerado pois n�o existe taxa para a moeda na data! Ref Ped Site: " + SC5->C5_NUMPVIM + ".",'E')
   EndIf
   //������������������������������������������������������������������������Ŀ
   //�Carrega perguntas do MATA410                                            �
   //��������������������������������������������������������������������������
   Pergunte("MTA410",.F.)
   RestArea(aArea)
Else
	Alert('O pedido nao foi faturado pois nao existe parametro CA_SERNF para faturamento automatico. Ref Ped Site: ' + SC5->C5_NUMPVIM + ".",'E')
EndIf
   
Return lContinua

User Function LoadNFS(aLiberada,aBloqueada)
Local aArea      := GetArea()
Local cAliasSC9  := ""
Local nPrcVen    := 0
Local nQtdLib    := 0
Local cSql       := ""

Default aLiberada    := {}
aBloqueada  := {}

	//��������������������������������������������������������������Ŀ
	//�Verifica se h� itens liberados                                �
	//����������������������������������������������������������������
	cAliasSC9 := CriaTrab(,.F.)
	cSql := "  select SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_SEQUEN,SC9.C9_QTDLIB,SC9.C9_QTDLIB2,"
	cSql += "         SC9.C9_PRCVEN,SC9.C9_PRODUTO,SC9.C9_LOCAL,SC9.C9_BLCRED,SC9.C9_BLEST,SC9.C9_BLWMS,"
	cSql += "         SC9.R_E_C_N_O_ C9_RECNO "
	cSql += "    from "+RetSqlName("SC9")+" SC9 "
	cSql += "   where SC9.C9_FILIAL = '" + xFilial("SC9") + "' "
	cSql += "     and SC9.C9_PEDIDO = '" + SC5->C5_NUM + "' "
	cSql += "     and SC9.D_E_L_E_T_=' ' "
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cSql)),cAliasSC9)
		
	While !Eof() .And. xFilial("SC9") == (cAliasSC9)->C9_FILIAL .And. SC5->C5_NUM == (cAliasSC9)->C9_PEDIDO
		If Empty((cAliasSC9)->C9_BLCRED+(cAliasSC9)->C9_BLEST) ;
		   .And. (Empty((cAliasSC9)->C9_BLWMS) .Or.;
		          (cAliasSC9)->C9_BLWMS == "05" .Or.;
		          (cAliasSC9)->C9_BLWMS == "07" ) 
	
			//��������������������������������������������������������������Ŀ
			//�Posiciona registros                                           �
			//����������������������������������������������������������������
			SC6->(DbSetOrder(1))
			SC6->(DbSeek(xFilial("SC6")+(cAliasSC9)->C9_PEDIDO+(cAliasSC9)->C9_ITEM+(cAliasSC9)->C9_PRODUTO))
			
			SE4->(DbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG) )
	
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
	
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2")+(cAliasSC9)->C9_PRODUTO+(cAliasSC9)->C9_LOCAL))
	
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))
			//������������������������������������������������Ŀ
			//� Verifica se o produto est� sendo inventariado  �
			//��������������������������������������������������
			If SF4->F4_ESTOQUE == 'S' .And. BlqInvent((cAliasSC9)->C9_PRODUTO,(cAliasSC9)->C9_LOCAL)
				// TODO -- LOG " Produto bloqueado por inventario. Pedido: " + (cAliasSC9)->C9_PEDIDO + ", Item: " + (cAliasSC9)->C9_ITEM + " Produto: " + (cAliasSC9)->C9_PRODUTO + " Local: " + (cAliasSC9)->C9_LOCAL + "."
				Alert(" Produto bloqueado por inventario. Pedido: " + (cAliasSC9)->C9_PEDIDO + ", Item: " + (cAliasSC9)->C9_ITEM + " Produto: " + (cAliasSC9)->C9_PRODUTO + " Local: " + (cAliasSC9)->C9_LOCAL + ".",'E')
			Else
				//��������������������������������������������������������������Ŀ
				//�Calcula o preco de venda                                      �
				//����������������������������������������������������������������		
				nPrcVen := (cAliasSC9)->C9_PRCVEN
				If ( SC5->C5_MOEDA <> 1 )
					nPrcVen := a410Arred(xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase,8),"D2_PRCVEN")
				EndIf
				
				//��������������������������������������������������������������Ŀ
				//�Monta array para geracao da NF                                �
				//����������������������������������������������������������������
				Aadd(aLiberada,{ (cAliasSC9)->C9_PEDIDO,;
				                 (cAliasSC9)->C9_ITEM,;
				                 (cAliasSC9)->C9_SEQUEN,;
				                 (cAliasSC9)->C9_QTDLIB,;
				                 nPrcVen,;
				                 (cAliasSC9)->C9_PRODUTO,;
				                 SF4->F4_ISS=="S",;
				                 (cAliasSC9)->C9_RECNO,;
				                 SC5->(RecNo()),;
				                 SC6->(RecNo()),;
				                 SE4->(RecNo()),;
				                 SB1->(RecNo()),;
				                 SB2->(RecNo()),;
				                 SF4->(RecNo()),;
				                 (cAliasSC9)->C9_LOCAL,;
				                 0,;
				                 (cAliasSC9)->C9_QTDLIB2} )
			EndIf
		ElseIf (cAliasSC9)->C9_BLCRED <> "10" .And. (cAliasSC9)->C9_BLEST <> "10"
			AAdd(aBloqueada,{(cAliasSC9)->C9_PEDIDO, (cAliasSC9)->C9_ITEM, (cAliasSC9)->C9_SEQUEN, (cAliasSC9)->C9_PRODUTO, TransForm((cAliasSC9)->C9_QTDLIB,X3Picture("C9_QTDLIB")), (cAliasSC9)->C9_BLCRED, (cAliasSC9)->C9_BLEST, (cAliasSC9)->C9_BLWMS})
		EndIf
		(cAliasSC9)->(DbSkip())
	EndDo
	(cAliasSC9)->(DbCloseArea())
	
RestArea(aArea)
Return Nil

Static aSerie := Nil
/* 
User Function GetFatProp(cFil , cLocal )
Local i 		:= 1
Local cSerie 	:= ""

Default	cFil 	:= SC6->C6_FILIAL
Default cLocal 	:= SC6->C6_LOCAL

If aSerie == Nil
   aSerie := {}	
   While (cSerie := GetNewPar("CA_SERNF"+StrZero(i,2),"ZZ") ) <> "ZZ"
      AAdd(aSerie, StrToKArr(cSerie, "|"))
      aSerie[Len(aSerie)][2] := &(aSerie[Len(aSerie)][2])
      aSerie[Len(aSerie)][3] := &(aSerie[Len(aSerie)][3])
      aSerie[Len(aSerie)][4] := &(aSerie[Len(aSerie)][4])
      i++
   End
EndIf

i := aScan( aSerie, { |aMat| aMat[1] = cFil + cLocal } )
 
Return Iif(i > 0, aSerie[i], { ,, .F. , .T. } )
 */
User Function ProcTransp()
Local cTransp := ""
Local lErro := .F.

	If SC5->C5_TPFRETE <> 'S' .and. !xFilial('SC5')$GetMV("CA_FILDF")
		// FOR�AR PROCESSAMENTO DA TRANSPORTADORA PARA PODER FATURAR A NOTA
		cTransp := SC5->C5_TRANSP
		If Empty(cTransp) .or. cTransp == "******"
			ConOut('[CFATA00A] Processamento de frete: ' + SC5->C5_FILIAL+'/'+SC5->C5_NUM )
			If (lErro := u_CGFEA003( SC5->(Recno()) ))     																					
				u_GerarLogMail("EI / Libera�ao de Pedido" , "Processo de integra�ao interrompido. Problema ao calcular frete do pedido site: " + SC5->C5_NUMPVIM , "E" )
			EndIf
		EndIf
	EndIf
	If xFilial('SC5')$GetMV("CA_FILDF") 
		RecLock('SC5',.F.)
			If SC5->C5_TPFRETE <> 'S'
				SC5->C5_TPFRETE := 'S'
			EndIf
			If SC5->C5_TRANSP == "******"
				SC5->C5_TRANSP := Space( TamSX3('C5_TRANSP')[1] )
			EndIf
		SC5->(MsUnLock())
	EndIf

Return lErro
