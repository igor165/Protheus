#INCLUDE "EECFAT2.ch"
#INCLUDE "APWIZARD.ch"
#INCLUDE "FWBROWSE.CH"
/*
Programa : EECFAT2
Objetivo : Integracao com Siga Advanced - Modulo Faturamento
Autor    : Cristiano A. Ferreira
Data/Hora: 10/11/1999 17:14
Obs.     :
*/


#include "EEC.CH"


//Defines para o rateio do frete
#Define RAT_PESO_LIQUIDO	"1"
#Define RAT_PESO_BRUTO		"2"
#Define RAT_PRECO			"3"

//aSavRat - mata461
#DEFINE SV_PEDIDO   	01
#DEFINE SV_FRETE    	02
#DEFINE SV_FRETAUT  	03
#DEFINE SV_SEGURO   	04
#DEFINE SV_DESPESA  	05
#DEFINE SV_DESCONT  	06
#DEFINE SV_DESPAC2  	07
#DEFINE SV_VLR_FRT  	08

Static aStrSC5,aStrEE7,aStrSC6,aStrEE8

/*
Funcao      : EECFAT2
Parametros  : nOpc,cTipo
              nOpc := 3 // Inclusao
                      4 // Alteracao
                      5 // Exclusao
              cTipo := "VLD" // Validacao
                       "GRV" // Gravacao
Retorno     : 
Objetivos   : 
Autor       : Cristiano A. Ferreira 
Data/Hora   : 10/11/1999 17:14      
Revisao     : 13/09/13 - correção na falha de integridade na alteração do pedido de exportação.
Obs.        : Convertido por CCF em 11/09/2000
*/
// Esta rotina considera que o EEC, ja esta posicionado.
Function EECFAT2(nOpc,cTipo)

Local lRet := .F.
//Local nOpc, cTipo

//Private cErrorLog := "" // Variavel utilizada para apresentar informacoes em caso de ERROR.LOG

CursorWait()

If( aStrSC5 = Nil , aStrSC5 := SC5->(dbStruct()) , ) 
If( aStrSC6 = Nil , aStrSC6 := SC6->(dbStruct()) , ) 
If( aStrEE7 = Nil , aStrEE7 := EE7->(dbStruct()) , )    
If( aStrEE8 = Nil , aStrEE8 := EE8->(dbStruct()) , )    

Begin Sequence
   /*
   IF ! ( ValType(ParamIXB) == "A" .And. Len(ParamIXB) > 1 )
      HELP(" ",1,"AVG0005021") //MsgStop("Erro nos parametros da rotina EECFAT !","Aviso")
      Break
   Endif   
   nOpc  := ParamIXB[1] 
   cTipo := ParamIXB[2]
   */
   
   IF cTipo == "VLD" // Validacao
      lRet := ValidFat(nOpc)
      IF !lRet
         Break
      Endif
   Elseif cTipo == "GRV" // Gravacao
      IF Empty(M->EE7_FATURA)
         lRet := .T.
         Break
      Endif
      
      lRet := GravaFat(nOpc)    
   ElseIf cTipo == "MSG" // Mensagem no Final da Gravacao                  
      // by OMJ 24/02/2003 a mensagem vai aparecer no final da gravacao e somente na inclusao.
      // If nOpc == 3 // Incluir
      // ISS - 05/08/2010 - A mensagem deve aparecer caso o pedido seja alterado e o parâmetro MV_EECFAT esteja ativado,
      // pois o pedido é integrado e o seu número não é informado
      If nOpc == 3 .Or. nOpc = 4 // Incluir ou Alterar

         //ER - 05/06/2007
         IF Empty(M->EE7_FATURA)
            lRet := .T.
            Break
         Endif
         
         IF ValType(EasyGParam("MV_EECAUTO")) == "L" .And. !EasyGParam("MV_EECAUTO") .And. !lFaturado .AND. !lEE7Auto //WHRS TE-7768 540063/ MTRADE-1723 - Exibição de MsgInfo na execução da rotina automática
            EECMsg(STR0001+Transf(M->EE7_PEDFAT,AVSX3("C5_NUM",AV_PICTURE)),STR0002) //"Número do Pedido no Faturamento: "###"Aviso"
         Endif
      Endif
      lRet := .t. // by CAF 26/06/2002 para Atualizar o contador do Pedido de Exp

   Else

      lRet := .t. // by CAF 26/06/2002 para Atualizar o contador do Pedido de Exp

   Endif
   
//   lRet := .t.  Claudia - travei pq perdia o controle de transacao  
End Sequence

CursorArrow()

Return lRet

/*
Funcao      : GravaFat
Parametros  : 
Retorno     : 
Objetivos   : Grava Pedido no SC5
Autor       : Cristiano A. Ferreira
Data/Hora   : 22/09/2000 13:34
Revisao     : Wilsimar Fabrício da Silva 11/02/2010
              Tratamentos para utilização da grade
Revisao     : Wilsimar Fabrício da Silva - 27/05/2010
              O faturamento trabalha com o conceito de primeira e segunda unidades de medidas
              do cadastro do produto.
              Neste caso, quando o pedido de exportação for criado usando a segunda unidade de medida
              do cadastro do produto, será necessário converter para a primeira antes de enviar para o faturamento.
Obs.        :
*/
Static Function GravaFat(nP_Opc)
LOCAL lALT,cCPOFAT,aVT,n1,n2

Local aOrd  := SaveOrd({"SA1","WorkIt","SB2"})

Local cCpoCont  := ""
Local cProdGrd  := ""
Local lMoedTit:= AllTrim(EasyGParam("MV_MOEDTIT",,"N")) == "S" .And.;
                    SC5->(FieldPos("C5_MOEDTIT")) > 0

Local dEntrega

Local lDeleta:= .F.
Local lRet   := .T.

//Local nPercDesconto :=  (EE7_DESCONT/EE7_TOTPED)
//Local nValrDesconto := 0
Local nInd      := 0, i
Local nDecTot   := AvSx3("D2_TOTAL",AV_DECIMAL)
Local nItemGr   := 0
Local nQuantDig := 0
Local nLinha    := 0
Local nColuna   := 0
Local nInc      := 0
Local nPos      := 0
Local nPosItGrd := 0
Local nCont     := 0
Local nSequencia:= 1
Local lSegUnMed:= .F.
Private lConvUnid  := .F.
Private cItem := "00", cUnidade:= "  "
Private nPrcUniMed := 0, nQtdUniMed := 0
Private nPesLiq := 0, nPesBru := 0  
Private nValorInc := 0, nDescAtu
private nTotItens := 0
Private aCab, aItens, aReg, nOpc := nP_OPC
Private lRet410 := .T. // utilizada no ponto de entrada "PE_FIM"
//DFS - 05/02/11 -  Chamada da função para que todos os campos que estão como usados no dicionários de dados sejam adicionados no array aSC6NaoAlt
Private aSC6NaoAlt := FAT2AltVlr()
Private nQtdVen      := 0  // GFP - 01/02/2013


Begin Sequence
   
   SA1->(dbSetOrder(1))
   WorkIt->(dbSetOrder(1))
   SB2->(dbSetOrder(1))

   // aCab por dimensao:
   // aCab[n,1] := Nome do Campo
   // aCab[n,2] := Valor a ser gravado no campo
   // aCab[n,3] := Regra de Validacao, se NIL considera do dicionario
   aCab := {}

   IF nOpc == 3 // Solicitar
      lALT := .F.
      IF ValType(EasyGParam("MV_EECAUTO")) == "L" .And. EasyGParam("MV_EECAUTO")
         aAdd(aCab,{"C5_NUM",AvKey(M->EE7_PEDIDO,"C5_NUM"),nil}) // Nro.do Pedido
      Else   
         /*
         aAdd(aCab,{"C5_NUM",GetSXENum("SC5"),nil}) // Nro.do Pedido
         ConfirmSx8() // JPP - 03/07/2006 - 09:30 - Atualizar a numeração automática definida pela função GetSXENum("SC5").
         */
         aAdd(aCab,{"C5_NUM",,}) // Nro.do Pedido         
      Endif
   Else
      lALT := .T.
      aAdd(aCab,{"C5_NUM",M->EE7_PEDFAT,nil})
   Endif

   aAdd(aCab,{"C5_TIPO","N",nil}) //Tipo de Pedido - "N"-Normal

   /* By JBJ - 17/05/04 - Enviar sempre o importador (Campo obrigatório). Não verifica as informações 
                          gravadas no campo do cliente. */
   /*
   IF !Empty(M->EE7_CLIENT)
      SA1->(dbSeek(xFilial()+M->EE7_CLIENT+M->EE7_CLLOJA))
   Else
      SA1->(dbSeek(xFilial()+M->EE7_IMPORT+M->EE7_IMLOJA))
   Endif
   */
   SA1->(dbSeek(xFilial()+M->EE7_IMPORT+M->EE7_IMLOJA))
   aAdd(aCab,{"C5_CLIENTE",SA1->A1_COD,nil})  //Cod. Cliente
   aAdd(aCab,{"C5_LOJACLI",SA1->A1_LOJA,nil}) //Loja Cliente
   aAdd(aCab,{"C5_TIPOCLI","X",nil}) //Tipo Cliente

   aAdd(aCab,{"C5_CONDPAG",Posicione("SY6",1,xFilial("SY6")+M->EE7_CONDPA+AvKey(M->EE7_DIASPA,"Y6_DIAS_PA"),"Y6_SIGSE4"),nil})
   ///aAdd(aCab,{"C5_TABELA","1",nil}) // Tabela de preco - Tabela 1

   IF WorkIn->(dbSeek("J"))
      aAdd(aCab,{"C5_BANCO",WorkIn->EEJ_CODIGO,nil}) // Banco
   Endif

   aAdd(aCab,{"C5_EMISSAO",M->EE7_DTPROC,nil})

/* AMS - 11/11/2004 às 11:16. Substituido a gravação do desconto na capa para gravar no item.
   aAdd(aCab,{"C5_DESC1",IF(M->EE7_PRECOA $ cSim,0,M->EE7_DESCON/M->EE7_TOTPED),nil})
*/

   aAdd(aCab,{"C5_MOEDA",POSICIONE("SYF",1,XFILIAL("SYF")+M->EE7_MOEDA,"YF_MOEFAT"),nil}) 
   aAdd(aCab,{"C5_PESOL",M->EE7_PESLIQ,nil}) 
   aAdd(aCab,{"C5_PBRUTO",M->EE7_PESBRU,nil}) 
   aAdd(aCab,{"C5_PEDEXP",M->EE7_PEDIDO,nil})

   //Geração de títulos na moeda estrangeira
   If lMoedTit
      AAdd(aCab,{"C5_MOEDTIT", Posicione("SYF", 1,xFilial("SYF") + M->EE7_MOEDA, "YF_MOEFAT"), Nil}) 
   EndIf
   
   // Um campo fórmula deve ser incluso no EECFAT e seu código colocado no parametro MV_AVG0111.
   // A fórmula de chamar a função Fat2ApTot(), que retorna o total do pedido.
   If EECFlags("COMMODITY") .and. IsIntFat() // FJH - 11/11/05
      aAdd(aCab,{"C5_REAJUST",EasyGParam("MV_AVG0111",,SPACE(3)),nil}) // adiciona o campo formula
   Endif 
   //Acb - 08/11/2010 - envio do desconto no pedido de exportação para o faturamento.
   If EasyGParam("MV_AVG0085",,.F.)
      aAdd(aCab,{"C5_DESCONT", M->EE7_DESCON, Nil}) 
   EndIf
   
   /*AOM - 27/08/10 - Quando  o parametro "MV_AVG0196"  estiver habilitado serão enviados os
                      campos Frete e seguro do pedido de exportação para o pedido de venda do 
                      Faturamento quando o porto for classificado como "Uruguaiana-RS" Rodoviario
                      de acordo com o comunicado "Uruguaiana, 30/06/2010. COMUNICADO PSR/URA Nº 0002/2010D". 
                      */
   If EasyGParam("MV_AVG0196",,.F.)
      ValidFrtSeg()  
   EndIf

   If EasyEntryPoint("EECFAT2")
      ExecBlock("EECFAT2",.F.,.F.,{"PE_GRVCAPA"})
   Endif

   For nInd := 1 TO Len(aStrSC5)
      cCampo := aStrSC5[nInd][1]
      If aScan(aCab,{|x| x[1] = cCampo }) = 0 .And. !("FILIAL"$cCampo)
         cCpoComum := SubStr(cCampo,4)        
         cCpoEE7   := Left("EE7_" + cCpoComum,10)
         If ( nPos := aScan(aStrEE7,{|x| x[1] = cCpoEE7 }) ) > 0 
            If aStrEE7[nPos][2] = aStrSC5[nInd][2] .And.;
               aStrEE7[nPos][3] = aStrSC5[nInd][3] .And.;
               aStrEE7[nPos][4] = aStrSC5[nInd][4] 
               
               bVar := MemVarBlock(cCpoEE7)
               If ValType(bVar) == "B" 
                  Aadd(aCab,{cCampo,Eval(bVar),Nil })
               EndIf
               
            EndIf                             
         EndIf
      EndIf
   Next

   // By JPP - 06/07/2006 - 15:30 - Correção na conversão dos dados enviados para o faturamento
   lConvUnid := (EE7->(FieldPos("EE7_UNIDAD")) # 0) .And. (EE8->(FieldPos("EE8_UNPES")) # 0) .And.;
                (EE8->(FieldPos("EE8_UNPRC"))  # 0)


   WORKIT->(dbGoTop())
   Do While WORKIT->(!Eof())
      If lConvUnid 
         nValorInc := ROUND((AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I,;
                             WorkIt->EE8_SLDINI,.F.)*WorkIt->EE8_PRECO), AvSx3("EE8_PRCTOT",AV_DECIMAL))
      Else
         nValorInc := ROUND(WORKIT->(EE8_PRECO*EE8_SLDINI), AvSx3("EE8_PRCTOT",AV_DECIMAL))
      EndIf
      
      nTotItens += nValorInc
      WORKIT->(DbSkip())
   EndDo


   nDescAtu := M->EE7_DESCON
   If EE7->(FieldPos("EE7_DSCORG")) > 0
      If M->EE7_DSCORG <> 0 .And. M->EE7_DESCON <> 0
         nDescAtu := M->EE7_DSCORG
      EndIf
   EndIf

   //cItem := "01"
   //MFR 04/04/2019 OSSME-2654
   IF nOpc == 3 .or. empty(M->EE7_PEDFAT)
       cItem := "01"
   Else
       cItem := SeqItem(cItem)
   EndIf
   aItens:= {}
   ////////////////////////////////////////////////////////////////
   //Tratamento para grade de produtos.                          //
   //Na utilização da grade, a WorkIt apresenta os itens da grade//
   //consolidados em apenas um registro. Aqui é realizada a      //
   //quebra de cada item da grade.                               //
   //WFS: Ao montar o array aItens, deve ser considerado a ordem //
   //dos itens do objeto grade para enviar ao faturamento. Também//
   //deve ser considerado os itens deletados da WorkIt e os itens//
   //apadados do objeto mas que o registro da WorkIt não foi     //
   //excluído.                                                   //
   //Quando o fluxo alternativo estiver habilitado, o array      //
   //aGrdRec virá com tamanho 0.                                 //
   ////////////////////////////////////////////////////////////////
   If lGrade

      //Itens restritos que não devem ser usados pela tabela EE8
      aItGrdRest:= {}
      EE8->(DBSetOrder(1)) //EE8_FILIAL + EE8_PEDIDO + EE8_SEQUEN + EE8_COD_I

      For nCont:= 1 To Len(aGrdRec)
      
         nItemGr:= 0

         //Verifica se é um item vindo do objeto grade
         If Len(aGrdRec[nCont][2]) > 0

            For nInc:= 1 To Len(aGrdRec[nCont][2])

               nQuantDig:= aGrdRec[nCont][2][nInc][1]
               cProdGrd := aGrdRec[nCont][2][nInc][2]
               lDeleta:= .F.

               //Serão adicionados todos os itens que foram alterados, inclusive os que a
               //quantidade passou a ser 0, sendo que o item deverá ser excluído do Faturamento.
               If nQuantDig == 0 .And.;
                  EE8->(DBSeek(xFilial() + M->EE7_PEDIDO + aGrdRec[nCont][nSequencia] + cProdGrd)) .And.;
                  EE8->EE8_GRADE $ cSim

                  nQuantDig:= EE8->EE8_SLDINI
                  AAdd(aDeletados, EE8->(RecNo()))
                  lDeleta:= .T.
               EndIf

               If nQuantDig > 0

                  nItemGr++

                  //Verifica a próxima sequência disponível para o item da grade
                  nItemGr:= AP102GrdItem(M->EE7_PEDIDO, aGrdRec[nCont][nSequencia], nItemGr, "SC6")

                  //Inclui no array aItGrdRest as sequências que não serão reaproveitadas na gravação
                  //dos registros na tabela EE8
                  If lDeleta

                     nPosItGrd:= AScan(aItGrdRest, {|x| x[1] == M->EE7_PEDIDO + aGrdRec[nCont][nSequencia]})

                     If nPosItGrd > 0
                        AAdd(aItGrdRest[nPosItGrd][2], nItemGr)
                     Else
                        AAdd(aItGrdRest, {M->EE7_PEDIDO + aGrdRec[nCont][nSequencia], {nItemGr}})
                     EndIf

                  EndIf

                  //Se o item não foi deletado da WorkIt...
                  If WorkIt->(DBSeek(aGrdRec[nCont][nSequencia]))

                     //... porém foi digitado quantidade 0, o campo "AUTODELETA" será gravado com "S",
                     If lDeleta .And. !Empty(M->EE7_PEDFAT)//Não é necessário enviar itens excluidos quando não existir o pedido de venda
                        GravaDelItens(nItemGr)
                        AAdd(aItens, AClone(aReg))

                     //senão, grava o campo "AUTODELETA" com "N",
                     Else
                        GravaItens(cProdGrd, nQuantDig, nItemGr)
                        AAdd(aItens, aClone(aReg))
                     EndIf
      
                     If Empty(WorkIt->EE8_FATIT)
                        WorkIt->EE8_FATIT:= cItem
                        cItem:= SomaIt(cItem)
                     EndIf
                  
                  //Se o item foi deletado da WorkIt, grava o campo "AUTODELETA" com "S" para todos os itens da sequência.
                  Else
                     If EE8->(DBSeek(xFilial() + M->EE7_PEDIDO + aGrdRec[nCont][nSequencia] + cProdGrd)) .And. !Empty(M->EE7_PEDFAT)//Não é necessário enviar itens excluidos quando não existir o pedido de venda
                        GravaDelItens(nItemGr)
                        AAdd(aItens, AClone(aReg))
                     EndIf
                  EndIf

               EndIf

            Next
               
         //Se a sequencia não é um item grade.
         Else

            //Se o item não foi deletado
            If WorkIt->(DBSeek(aGrdRec[nCont][nSequencia]))
               GravaItens()
               AAdd(aItens, aClone(aReg))

               If Empty(WorkIt->EE8_FATIT)
                  WorkIt->EE8_FATIT:= cItem
                  cItem:= SomaIt(cItem)
               EndIf
            //Se o item foi deletado
            Else
               If EE8->(DBSeek(xFilial() + M->EE7_PEDIDO + aGrdRec[nCont][nSequencia])) .And. !Empty(M->EE7_PEDFAT)//Não é necessário enviar itens excluidos quando não existir o pedido de venda
                  GravaDelItens()
                  AAdd(aItens, AClone(aReg))
               EndIf
            EndIf
         EndIf

      Next
      
   //Se o recurso grade está desabilitado
   Else

      If !Empty(M->EE7_PEDFAT)//Não é necessário enviar itens excluidos quando não existir o pedido de venda
         //Registros deletados
         For nCont:= 1 To Len(aDeletados)
            EE8->(DBGoTo(aDeletados[nCont]))
            GravaDelItens()
            AAdd(aItens, AClone(aReg))
         Next
      EndIf

      //Registros incluídos/ alterados
      WorkIt->(DBGoTop())
      While WorkIt->(!Eof())
  
         GravaItens()
         AAdd(aItens, aClone(aReg))

         If Empty(WorkIt->EE8_FATIT)
            WorkIt->EE8_FATIT:= cItem
            cItem:= SomaIt(cItem)
         EndIf

         WorkIt->(DBSkip())
      EndDo
   EndIf
   WorkIt->(DBGoTop())
   
   If lIntEmb
      //////////////////////////////////////////////////////////////////////////////////////
      //A variavel lAtuPesEmb é declarada na função FAT3PVSaldo, e indica se o peso já foi//
      //calculado por essa função.                                                        //
      //Caso a variavel não exista ou seja .F., é porque a Função EECAFAT2.prw não foi    //
      //chamada pela atualização do embarque, mas diretamente pela manutenção de          //
      //Pedido de Exportação.                                                             //
      //////////////////////////////////////////////////////////////////////////////////////
      If Type("lAtuPesEmb") <> "L" .or. !lAtuPesEmb
         If nOpc == ALTERAR
            //////////////////////////////////////////////////////////////////////////
            //O Peso do Pedido de Venda Filho deverá ser calculado com base no Saldo//
            //e não na Quantidade, quando a integração alternativa está habilidade. //
            //////////////////////////////////////////////////////////////////////////
            If (nPos := aScan(aCab, {|x| x[1] == "C5_PESOL"})) > 0
               aCab[nPos][2] := nPesLiq
            EndIf

            If (nPos := aScan(aCab, {|x| x[1] == "C5_PBRUTO"})) > 0
               aCab[nPos][2] := nPesBru
            EndIf
         EndIf
      EndIf
   EndIf

   /* WFS
      Quando grade, a ordem de gravação do array será a mesma de como são apresentados no objeto.
      A alteração desta ordem gerará estouro de array na função Ma410GraGr(). */
   If lGrade .And. Len(aGrdRec) > 0
      ASort(aItens,,, {|x, y|  x[2][2] + x[3][2] < y[2][2] + y[3][2]})
   Else
      ASORT(aItens,,, { |x, y| x[2,2] < y[2,2] }) //Claudia
   EndIf
   
   //RMD - 23/09/13 - Abate o valor do frete já embutido no valor unitário do item, que será enviado somado ao frete total
   If EasyGParam("MV_AVG0196",,.F.) .And. EasyGParam("MV_EEC0039",,.F.) .And. EE7->(FieldPos("EE7_FREEMB")) > 0 .And. M->EE7_FREEMB > 0 .And. FindFunction("EasyRateio")
      oRateio := EasyRateio():New(M->EE7_FREEMB, nTotItens, Len(aItens), AvSx3("C6_PRCVEN", AV_DECIMAL))
      For i := 1 To Len(aItens)
         If (nPosAUTDEL := aScan(aItens[i], {|x| x[1] == "AUTDELETA"})) == 0 .Or. aItens[i][nPosAUTDEL][2] <> "S"
         	nPosPRCVEN  := aScan(aItens[i], {|x| x[1] == "C6_PRCVEN" })
         	nPosPRUNIT  := aScan(aItens[i], {|x| x[1] == "C6_PRUNIT" })
         	nPosQTDVEN  := aScan(aItens[i], {|x| x[1] == "C6_QTDVEN" })
         	nValorItem  := oRateio:GetItemRateio(aItens[i][nPosPRCVEN][2])
         	aItens[i][nPosPRCVEN][2] -= (nValorItem / aItens[i][nPosQTDVEN][2])
         	aItens[i][nPosPRUNIT][2] := aItens[i][nPosPRCVEN][2]
         EndIf
      Next
   EndIf

   /*
   Substituido a função ExecMata pela função AVMata410.
   Objetivo    : Manter em uma unica função as rotinas de geração de log, validação e integração com Faturamento.
   Autor       : Alexsander Martins dos Santos
   Data e Hora : 24/03/2004 às 15:42.
   */
   lRet := AVMata410(aCab, aItens, nOpc)

   If EasyEntryPoint("EECFAT2")
      lRet410 := lRet
      ExecBlock("EECFAT2",.F.,.F.,{"PE_FIM"})
   Endif

End Sequence

RestOrd(aOrd,.T.)

Return lRet



/*
Funcao      : GravaDelItens
Parametros  : nItemGr - sequência do item da grade
Retorno     : 
Objetivos   : Gravar os dados do registro deletado, corrente na tabela EE8, no array aReg,
              para depois adicioná-lo no array aItens, usado para a integração com o Faturamento
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 02/03/2010
Revisao     : 
Obs.        :
*/
Static Function GravaDelItens(nItemGrd)
Local lSegUnMed:= .F.
Default nItemGrd:= 0

Begin Sequence

      aReg:= {}
      
      If SB1->(DBSeek(xFilial() + EE8->EE8_COD_I))
         If !SB2->(DBSeek(xFilial() + SB1->B1_COD + SB1->B1_LOCPAD))
            CriaSB2(SB1->B1_COD, SB1->B1_LOCPAD)
         EndIf
      EndIf
      
      aAdd(aReg, {"C6_NUM", aCab[1][2], Nil})
      aAdd(aReg, {"C6_ITEM", EE8->EE8_FATIT, Nil}) //Item sequencial

      If EE8->EE8_FATIT > cItem
         cItem:= EE8->EE8_FATIT
      EndIf

      cUnidade  := EE8->EE8_UNIDAD
      nPrcUniMed:= EE8->EE8_PRECOI
      
      If lConvUnid      

         /* ER - 21/07/2006 - Caso a Unidade do Preço seja diferente da Unidade de Quantidade, 
                             o Preço será convertido para a Unidade dae Quantidade. */
         
         If !Empty(EE8->EE8_UNPRC) .And. EE8->EE8_UNPRC <> EE8->EE8_UNIDAD    
            nQtdUniMed:= AvTransUnid(EE8->EE8_UNPRC,cUnidade,EE8->EE8_COD_I,1,.F.)
            nPrcUniMed:= ROUND(EE8->EE8_PRECOI/nQtdUniMed,AvSx3("EE8_PRECOI",AV_DECIMAL))
         EndIf
      EndIf

      lSegUnMed:= If(AllTrim(EE8->EE8_UNIDAD) == AllTrim(SB1->B1_SEGUM), .T., .F.)

      If lSegUnMed
         Fat2SegUnidade(@cUnidade, @nQtdVen, @nPrcUniMed)
      EndIf

      aAdd(aReg,{"C6_PRODUTO",EE8->EE8_COD_I ,nil}) // Cod.Item

      aAdd(aReg,{"C6_UM"     ,cUnidade,nil}) // Unidade

      aAdd(aReg,{"C6_QTDVEN" ,EE8->EE8_SLDINI,nil}) // Quantidade
   
      aAdd(aReg,{"C6_PRCVEN" ,nPrcUniMed,nil}) // Preco Unit.

      If EE8->(FieldPos("EE8_OPER")) > 0 .And. !Empty(EE8->EE8_OPER)    
         aAdd(aReg,{"C6_OPER",EE8->EE8_OPER,nil})  //Tipo de Operação(Tes Inteligente)
      Else
         // ** JBJ - 05/09/01 - 11:51
         aAdd(aReg,{"C6_TES",EE8->EE8_TES,nil}) // Tipo de Saida 
         aAdd(aReg,{"C6_CF",EE8->EE8_CF,nil})  // Classificacao Fiscal 
      EndIf

      //MPG - 01/02/19 - Verifica se existe o campo local para integrar do pedido de exportação
      If EE8->(FieldPos("EE8_LOCAL")) > 0 //.and. WorkIt->(FieldPos("EE8_LOCAL")) > 0 
         aAdd(aReg,{"C6_LOCAL",EE8->EE8_LOCAL,nil}) 
      else
         //MFR 03/04/2019 OSSME-2654
         aAdd(aReg,{"C6_LOCAL",SB1->B1_LOCPAD,nil})  // Almoxarifado      
      Endif

      dEntrega := EE8->EE8_DTENTR

      IF Empty(dEntrega)
         dEntrega := EE8->EE8_DTPREM
      Endif

      aAdd(aReg,{"C6_ENTREG",dEntrega,nil})  // Dt.Entrega
      aAdd(aReg,{"C6_DESCRI",SB1->B1_DESC,nil})
                        
      //DFS - 23/02/11 - Tratamento para que o campo do faturamento receba o valor preenchido no Pedido de Exportação.
      If EE8->(FieldPos("EE8_RESERV")) > 0  // WorkIt->(FieldPos("EE8_RESERV")) > 0 
         aAdd(aReg,{"C6_RESERVA",EE8->EE8_RESERV,nil}) 
      Endif

      //WFS - Tratamentos para quando for item da grade
      If lGrade
         If nItemGrd > 0
            AAdd(aReg, {"C6_GRADE"  , "S", Nil})
            AAdd(aReg, {"C6_ITEMGRD", StrZero(nItemGrd, AVSX3("C6_ITEMGRD", AV_TAMANHO)), Nil})
         Else
            AAdd(aReg, {"C6_GRADE"  , "N", Nil})
            AAdd(aReg, {"C6_ITEMGRD", Nil, Nil})
         EndIf
      EndIf

      aAdd(aReg,{"AUTDELETA","S",nil})

      If EasyEntryPoint("EECFAT2")
         ExecBlock("EECFAT2",.F.,.F.,{"PE_DELITEM"})
      Endif

lSegUnMed:= .F.
End Sequence
Return


/*
Funcao      : GravaItens
Parametros  : 
Retorno     : 
Objetivos   : Gravar os dados do registro corrente na WorkIt, no array aReg, para depois
              adicioná-lo ao array aItens, usado para a integração com o Faturamento.
Autor       : Eduardo Romanini
Data/Hora   : 12/2009
Revisao     : WFS - 26/02/2010
Obs.        :
*/

*--------------------------------------------------------------*
Static Function GravaItens(cProduto,nQuant,nItemGr)
*--------------------------------------------------------------*
Local cNrFatIt := "  "
Local cCF      := ""
Local cTES     := ""
Local cAutoDel := "N"

Local i    := 0
Local nInd := 0
Local nPos := 0

//Local nQtdVen      := 0  // Nopado por GFP - 01/02/13
Local nValorFob    := 0
Local nDesconto    := 0
Local nPorcento    := 0
Local nDecDesc     := AvSx3("D2_DESCON",AV_DECIMAL)
Local nDecPrc      := AvSx3("D2_PRCVEN",AV_DECIMAL)
Local nPosDesconto := 0
Local nTotDesc     := 0
Local nSldAtu      := 0

Local dEntrega
Local lSegUnMed := .F.   // GFP - 03/10/2012
Local lOpcPadrao:= GetNewPar("MV_REPGOPC","N") == "N" //LRS - 20/10/2015
Local cTpOper   := ""
Local aNaoEnviaSC6 := {"C6_FILIAL"}

Default cProduto := WorkIt->EE8_COD_I
Default nQuant   := WorkIt->EE8_SLDINI
Default nItemGr  := 0


Begin Sequence
       
      IF SB1->(dbSeek(xFilial()+AvKey(cProduto,"B1_COD")))

         //WFS 27/05/2010
         lSegUnMed:= If(AllTrim(WorkIt->EE8_UNIDAD) == AllTrim(SB1->B1_SEGUM), .T., .F.)
      
         IF ! SB2->(dbSeek(xFilial()+SB1->B1_COD+SB1->B1_LOCPAD))
            CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
         Endif
      Endif 

      If lConvUnid
         nQtdVen := AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I,nQuant,.F.) 
      Else
         nQtdVen := nQuant
      EndIf
      
      ///////////////////////////////////////////////////
      //Cálculo do saldo do item para grade de produtos//
      ///////////////////////////////////////////////////
      If lGrade
         If nOpc == INCLUIR
            nSldAtu := nQuant
         Else
            EE8->(DbSetOrder(1)) //EE8_FILIAL + EE8_PEDIDO + EE8_SEQUEN + EE8_COD_I
            If EE8->(DbSeek(xFilial("EE8")+M->EE7_PEDIDO+WorkIt->EE8_SEQUEN+AvKey(cProduto,"EE8_COD_I")))
               If nQuant <> EE8->EE8_SLDINI
                  If EE8->EE8_SLDINI == EE8->EE8_SLDATU
                     nSldAtu := nQuant
                  Else
                     If nQuant > EE8->EE8_SLDINI
                        nSldAtu := EE8->EE8_SLDATU + nQuant
                     Else
                        nSldAtu := EE8->EE8_SLDATU - nQuant
                     EndIf
                  EndIf
               Else
                  nSldAtu := EE8->EE8_SLDATU
               EndIf
            Else
               nSldAtu := nQuant
            EndIf
         EndIf
      Else
         nSldAtu := WorkIt->EE8_SLDATU
      EndIf
     
      aReg := {}

      cNrFatIt := If(Empty(WorkIt->EE8_FATIT),cItem,WorkIt->EE8_FATIT)
      
      aAdd(aReg,{"C6_NUM",aCab[1,2],nil}) // Código do Pedido de Venda
      aAdd(aReg,{"C6_ITEM",cNrFatIt,nil}) // Item sequencial
            
      nQtdVen    := WORKIT->EE8_SLDINI
      cUnidade   := WorkIt->EE8_UNIDAD
      nPrcUniMed := WorkIt->EE8_PRECOI
      nSaldo     := WorkIt->EE8_SLDATU      
      
      If lConvUnid      
         
         /* ER - 21/07/2006 - Caso a Unidade do Preço seja diferente da Unidade de Quantidade, 
                             o Preço será convertido para a Unidade dae Quantidade.
         */
         If !Empty(WorkIt->EE8_UNPRC) .And. WorkIt->EE8_UNPRC <> WorkIt->EE8_UNIDAD .And. SB1->B1_UM <> WorkIt->EE8_UNPRC      
            nQtdUniMed := AvTransUnid(WorkIt->EE8_UNPRC,cUnidade,WorkIt->EE8_COD_I,1,.F.)
            
            nPrcUniMed := ROUND(WorkIt->EE8_PRECOI/nQtdUniMed,AvSx3("EE8_PRECOI",AV_DECIMAL))
         EndIf
      EndIf

      //WFS 27/05/2010
      //Conversão da segunda unidade de medida, conforme o cadastro do produto.
      //Sempre será enviada a quantidade e o valor conforme a primeira unidade de medida.
      If lSegUnMed
         aAdd(aReg,{"C6_UNSVEN",nQtdVen,nil}) //DFS - 22/09/2011 - Inclusão de tratamento para segunda unidade de medida quando o PE for alterado
         //aAdd(aReg,{"C6_QTDVEN",nQtdVen,nil})  //DFS - 22/09/2011 - Inclusão de tratamento para quantidade de venda quando o PE for alterado       
         Fat2SegUnidade(@cUnidade, @nQtdVen, @nPrcUniMed, @nSaldo)
      EndIf
      nQuant:= nQtdVen
      /*
         RMD - 04/05/08
         Quando possuir Commodity, geralmente o pedido é gerado sem possuir um preço inicial, que será definido 
         pela RV. Desta forma, é enviado o preço 0.01 para que o faturamento aceite o item sem preço.
      */
      If (nPrcUniMed == 0) .And. EECFlags("COMMODITY")
         nPrcUniMed := 0.01
      EndIf
     
      aAdd(aReg,{"C6_PRODUTO",cProduto,nil}) // Cod.Item
      aAdd(aReg,{"C6_UM",cUnidade,nil}) // Unidade

      If lIntEmb
         /////////////////////////////////////////////////////////////
         //Caso a integração a partir do embarque esteja habilitada,//
         //o saldo do Pedido de Exportação que será gravado no      //
         //Pedido de venda.                                         //
         /////////////////////////////////////////////////////////////
         If nSldAtu > 0
            aAdd(aReg,{"C6_QTDVEN",nSldAtu,nil}) // Saldo
         Else
            //////////////////////////////////////////////////////////////////////////////////////////
            //Se o saldo for zero, a quantidade inicial será passada apenas para que não seja gerado//
            //erro na integração (Validação de Quantidade diferente de zero). A quantidade do item  //
            //no Pedido de Venda será zerada manualmente.                                           //
            //////////////////////////////////////////////////////////////////////////////////////////
            aAdd(aReg,{"C6_QTDVEN",nQuant,nil}) // Quantidade
         EndIf
         
         nPesLiq += CalcPeso(WorkIt->EE8_PEDIDO,WorkIt->EE8_FATIT,nSldAtu,aCab[1][2])[1]
         nPesBru += CalcPeso(WorkIt->EE8_PEDIDO,WorkIt->EE8_FATIT,nSldAtu,aCab[1][2])[2]
         
      Else
         aAdd(aReg,{"C6_QTDVEN",nQuant,nil}) // Quantidade
      EndIf
      
      aAdd(aReg,{"C6_PRCVEN", nPrcUniMed, nil}) // Preco Unit.
      aAdd(aReg,{"C6_PRUNIT",nPrcUniMed,nil}) // Preco Unit.
      
      If lConvUnid
         nValorFOB := ROUND((AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I,;
                                   nQuant,.F.)*WorkIt->EE8_PRECOI),AvSx3("EE8_PRCINC",AV_DECIMAL))
         nValorInc := ROUND((AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I,;
                                   nQuant,.F.)*WorkIt->EE8_PRECO),AvSx3("EE8_PRCTOT",AV_DECIMAL))
      Else
         nValorFOB     := Round(WorkIt->(nQuant*EE8_PRECOI),AvSx3("EE8_PRCINC",AV_DECIMAL))
         nValorInc     := Round(WorkIt->(nQuant*EE8_PRECO),AvSx3("EE8_PRCTOT",AV_DECIMAL))
      EndIf
      //Acb - 08/11/2010 - Caso o parêmetro esteja ligado não é rateado o desconto no itens e somente no total do processo.
      If !EasyGParam("MV_AVG0085",,.F.)
         nDesconto := 0
      
         If nDescAtu <> 0 //JPM - só corrige qdo há desconto.

            nPorcento := Round(nValorInc/nTotItens, 8)
            nDesconto := Round((nPorcento * nDescAtu), 8)   
            nDesconto := Round(nDesconto/nQtdVen,nDecPrc)

            nDesconto := Round(nDesconto*nQtdVen,nDecDesc)
         EndIf      

         //FJH 07/02/06 - Adaptação desconto por item      
         If EasyGParam("MV_AVG0119",,.F.) .and. EE8->(FieldPos("EE8_DESCON")) > 0
            nDesconto := WorkIt->EE8_DESCON
            aAdd(aReg,{"C6_VALDESC", nDesconto, nil})
         Else
            aAdd(aReg,{"C6_VALDESC",nDesconto, nil}) // Percentual de desconto por item.
         Endif
      Endif
      
      nPosDesconto := aScan(aReg,{|x| x[1] = "C6_VALDESC"})
      IF nPosDesconto > 0
         nTotDesc += aReg[nPosDesconto, 2]
      Endif

      //MFR 08/09/2021 Se tem TES Inteligente, ela deve ser informada nesta ordem
      If EE8->(FieldPos("EE8_OPER")) > 0 .And. !Empty(WorkIt->EE8_OPER)     
         aAdd(aNaoEnviaSC6,"C6_TES")
         aAdd(aNaoEnviaSC6,"C6_CF")
         aAdd(aReg,{"C6_OPER", WorkIt->EE8_OPER,nil}) //Tipo de Operação(Tes Inteligente)               
      EndIf
                
      //MPG - 01/02/19 - Verifica se existe o campo local para integrar do pedido de exportação
      If EE8->(FieldPos("EE8_LOCAL")) > 0 .and. WorkIt->(FieldPos("EE8_LOCAL")) > 0
         aAdd(aReg,{"C6_LOCAL",WorkIt->EE8_LOCAL,nil}) 
      else
         aAdd(aReg,{"C6_LOCAL",SB1->B1_LOCPAD,nil})  // Almoxarifado
      Endif

     
      dEntrega := WorkIt->EE8_DTENTR
      
      IF Empty(dEntrega)
         dEntrega := WorkIt->EE8_DTPREM
      Endif
      
      aAdd(aReg,{"C6_ENTREG",dEntrega,nil})  // Dt.Entrega
      
      aAdd(aReg,{"C6_DESCRI",SB1->B1_DESC,nil})
      
      If lGrade
         If nItemGr > 0
            aAdd(aReg,{"C6_GRADE"  ,"S",nil})
            aAdd(aReg,{"C6_ITEMGRD",StrZero(nItemGr,AVSX3("C6_ITEMGRD",AV_TAMANHO)),nil})
         Else
            aAdd(aReg,{"C6_GRADE"  ,"N",nil})
            aAdd(aReg,{"C6_ITEMGRD",nil,nil})
         EndIf
      EndIf

	  /*LGS-17/01/2014
	    Quando tiver liberação de pedido parcial e já tiver emitido nota deve manter o saldo já entregue para que não se tenha
	    o saldo inicial como total para poder ser liberado novamente, este erro é possivel com liberação parcial e já faturado.*/	  
      If !Empty(aCab[1,2]) .And. SC6->(DBSEEK(xFilial("SC6")+aCab[1,2]+cNrFatIt+cProduto)) 
      	If !Empty(SC6->C6_QTDENT)
      		aAdd(aReg,{"C6_QTDENT",SC6->C6_QTDENT,nil})
      	EndIf
      EndIf
      
      //LRS - 20/10/2015 - Acrescentando os campos de opcionais ao array aReg, caso tenha os campos aplicado no EEC
      IF EE8->(FieldPos("EE8_OPC")) > 0 .And. EE8->(FieldPos("EE8_MOP")) > 0
	      IF lOpcPadrao
	         aAdd(aReg,{"C6_OPC",WorkIt->EE8_OPC,nil})
	      Else
	         aAdd(aReg,{"C6_MOPC",WorkIt->EE8_MOP,nil})
	      EndIF
      EndIF
        /* 
         Verifica os Campos do EE8 que possuem a mesma terminação de nome dos campos
         do SC6, caso encontre e o campo estja preenchido, adiciona esses campos no 
         array para serem gravados no SC6. */
		
      For nInd := 1 TO Len(aStrSC6)
         cCampo := aStrSC6[nInd][1]
         If aScan(aReg,{|x| x[1] == cCampo }) == 0 .And. AScan(aNaoEnviaSC6, cCampo) == 0
            cCpoComum := SubStr(cCampo,4)        
            cCpoEE8   := Left("EE8_" + cCpoComum,10)
           If ( nPos := aScan(aStrEE8,{|x| x[1] = cCpoEE8 }) ) > 0 
               If aStrEE8[nPos][2] = aStrSC6[nInd][2] .And.;
                  aStrEE8[nPos][3] = aStrSC6[nInd][3] .And.;
                  aStrEE8[nPos][4] = aStrSC6[nInd][4] 
                  //DFS - 08/04/2011 - Tratamento para quando alterar o valor no Embarque, transmita ao Faturamento
                  If WorkIt->(FieldPos(cCpoEE8)) > 0 //.And. !Empty(WorkIt->(FieldGet(FieldPos(cCpoEE8))))
                     If (nPos:= AScan(aReg, {|x| x[1] == AllTrim(cCampo)})) > 0
                        aReg[nPos][2]:= WorkIt->(FieldGet(FieldPos(cCpoEE8)))
                     Else
                        Aadd(aReg,{cCampo,WorkIt->(FieldGet(FieldPos(cCpoEE8))),Nil })
                     EndIf
                  EndIf
               
               EndIf                             
            EndIf
         EndIf
      Next   



	  //ER - 29/04/2008 - Posiciona no Item do Pedido de Venda não perder informações já gravadas.
      If nOpc == ALTERAR
         SC6->(DbSetOrder(1))
         If SC6->(DbSeek(xFilial("SC6")+AvKey(aCab[1,2],"C6_NUM")+AvKey(aReg[2,2],"C6_ITEM")))
            //////////////////////////////////////////////////////////////////////////////////////////
            //Verifica se os campos do array aSC6NaoAlt estão preenchidos no Pedido de Venda.       //
            //Em Caso Positivo grava o seu valor no array aReg para que as informações desses campos//
            //não sejam alteradas no Pedido de Venda.                                               //
            //////////////////////////////////////////////////////////////////////////////////////////

            //DFS - 05/02/11 - Adicionado tratamento para filtrar os campos que não estão no array e adicioná-los para não haver perda de informações ao alterar um Ped. Export
            For i:=1 To Len(aSC6NaoAlt)//FSY - 12/09/2013 - chamado 102851
               If (nPos := aScan(aReg, {|x| x[1] == aSC6NaoAlt[i] })) > 0
                  If Empty(aReg[nPos][2]) .And. Empty(SC6->&(aSC6NaoAlt[i]))
	                  IF (aReg[nPos][1]) <> AllTrim("C6_LOTECTL") //LRS - 20/10/2016 - Não deletar o Campo C6_LOTECTL para não dar erro na integração
                     aDel(aReg, nPos)
                     aSize(aReg, Len(aReg) - 1)
                  EndIf
                  EndIF
               EndIf
            Next
         EndIf
      EndIf

	  //LRS - 30/10/2015 - Devido ao recalculo de preço existente no faturamento, ao preencher o campo C6_LOTECTL, é necessário informar o preço por ultimo.
      IF EE8->(FieldPos("EE8_OPC")) > 0 .And. EE8->(FieldPos("EE8_MOP")) > 0 .AND. (nPos:= AScan(aReg, {|x| x[1] == AllTrim("C6_LOTECTL") .AND. Empty(X[2])})) > 0
         If (nPos:= AScan(aReg, {|x| x[1] == AllTrim("C6_PRCVEN")})) > 0 
            aDel(aReg, nPos)
            aSize(aReg, Len(aReg) - 1)
         EndIF
         If (nPos:= AScan(aReg, {|x| x[1] == AllTrim("C6_PRUNIT")})) > 0 
            aDel(aReg, nPos)
            aSize(aReg, Len(aReg) - 1)
         EndIF
         If (nPos:= AScan(aReg, {|x| x[1] == AllTrim("C6_VALDESC")})) > 0 
            nDesconto := aReg[nPos][2]
            aDel(aReg, nPos)
            aSize(aReg, Len(aReg) - 1)
         EndIF
        
         aAdd(aReg,{"C6_PRCVEN", nPrcUniMed, nil}) // Preco Unit.
         aAdd(aReg,{"C6_PRUNIT", nPrcUniMed, nil}) // Preco Lista. 

         If !EasyGParam("MV_AVG0085",,.F.)
            aAdd(aReg,{"C6_VALDESC", nDesconto, nil}) // Desconto
         EndIf

      EndIF

      /* wfs 13/11/2019: quando é alteração do pedido de venda, se não houver alteração no valor do desconto do item, o preço unitário não é recalculado.
         O faturamento gatilha pela validação do campo, função A410MultT, que só é executada quando há alteração do conteúdo do campo de desconto.
         Quando o desconto tiver que ser considerado na formação de preço do item, o preço unitário será reenviado após o campo desconto, já com o valor apurado
         conforme a regra do próprio sigafat. */
      If !EasyGParam("MV_AVG0085",,.F.)
         aAdd(aReg,{"C6_PRCVEN", FtDescItem(nPrcUniMed, nPrcUniMed, nQuant, WorkIt->EE8_PRCTOT, Nil, nDesconto, 0, 2), Nil})// Preco Unit.
      EndIf

      //MFR 08/09/2021 Se não tem TES Inteligente, a tes normal tem que ser informada nesta ordem
      If EE8->(FieldPos("EE8_OPER")) == 0 .or. Empty(WorkIt->EE8_OPER) 
         cTES := "501"
         IF WorkIt->(FieldPos("EE8_TES")) > 0 .And. !Empty(WorkIt->EE8_TES)
            cTES := WorkIt->EE8_TES
         Endif
         
         cCF := "663"
         IF WorkIt->(FieldPos("EE8_CF")) > 0 .And. !Empty(WorkIt->EE8_CF)
            cCF := WorkIt->EE8_CF
         Endif                
         
         aAdd(aNaoEnviaSC6,"C6_OPER")        
         aAdd(aReg,{"C6_TES",cTES,nil}) // Tipo de Saida                
         aAdd(aReg,{"C6_CF",cCF,nil})  // Classificacao Fiscal
      EndIf

      AAdd(aReg, {"AUTDELETA", cAutoDel, Nil})

      If EasyEntryPoint("EECFAT2")
         ExecBlock("EECFAT2",.F.,.F.,{"PE_GRVITEM"})
      Endif

End Sequence

Return Nil


/*
Funcao      : ValidFat
Parametros  : 
Retorno     : 
Objetivos   : Critica dados do Pedido
Autor       : Cristiano A. Ferreira
Data/Hora   : 22/09/2000 13:38
Revisao     :
Obs.        :
*/
Static Function ValidFat(nOpc)

Local lRet := .T.
Local aOrd := SaveOrd({"SA1","WorkIt"})
Local cItem

Begin Sequence

   SA1->(dbSetOrder(1))
   WorkIt->(dbSetOrder(1))

   /* By JBJ - 17/05/04 - Somente as informações do importador são enviadas ao faturamento.
                          Dessa forma não valida o código do cliente. */
   /*
   IF !Empty(M->EE7_CLIENT)
      IF ! SA1->(dbSeek(xFilial()+M->EE7_CLIENT+M->EE7_CLLOJA))
         HELP(" ",1,"AVG0005022") //MsgStop("Cliente não cadastrado !","Aviso")
         lRet := .f.
         Break
      Endif
   Else
      IF ! SA1->(dbSeek(xFilial()+M->EE7_IMPORT+M->EE7_IMLOJA))
         HELP(" ",1,"AVG0005023") //MsgStop("Importador não cadastrado !","Aviso")
         lRet := .f.
         Break
      Endif
   Endif
   */
   If !SA1->(dbSeek(xFilial()+M->EE7_IMPORT+M->EE7_IMLOJA))
      EECHelp(" ",1,"AVG0005023") //MsgStop("Importador não cadastrado !","Aviso")
      lRet := .f.
      Break
   Endif

   M->EE7_FATURA:=dDATABASE

   //FDR - 22/02/13
   IF nOpc == 3 .AND. M->EE7_AMOSTR == "1" //.AND. !EECMsg(STR0003, STR0004, "MsgNoYes") //"Deseja registrar Amostra no SIGAFAT ?"###"Integração"  // GFP - 15/06/2015
      M->EE7_FATURA:=CTOD("")
   ElseIf M->EE7_AMOSTR == "1" .AND. !SC5->(DbSeek(xFilial("SC5")+M->EE7_PEDFAT)) .AND. nOpc <> 3 //.AND. !EECMsg(STR0003, STR0004, "MsgNoYes")  // GFP - 15/06/2015
      M->EE7_FATURA:=CTOD("")
   Else 
      // verifica cond.pagto e moeda
      IF Empty(Posicione("SY6",1,xFilial("SY6")+AvKey(M->EE7_CONDPA,"Y6_COD")+AvKey(M->EE7_DIASPA,"Y6_DIAS_PA"),"Y6_SIGSE4"))
         EECHelp(" ",1,"AVG0005024") //MsgStop("O campo Cond.Pagto no SIGA não foi digitado no cadastro de Cond.Pagto","Aviso")
         lRet := .F.
         Break
      Endif
      
      IF Empty(Posicione("SYF",1,xFilial("SYF")+AvKey(M->EE7_MOEDA,"YF_MOEDA"),"YF_MOEFAT"))
         EECHelp(" ",1,"AVG0005025") //MsgStop("O campo Moeda no SIGA  não foi digitado no cadastro de Moedas","Aviso")
         lRet := .F.
         Break
      Endif
   ENDIF
   
   cItem := "01"
   WorkIt->(dbGoTop())
   
   While  ! WorkIt->(Eof())
      cItem := SomaIt(cItem)
      
      IF cItem > "Z9"
         EECHelp(" ",1,"AVG0005026") //MsgStop("Excedeu o limite de itens do SIGAFAT !")
         lRet := .F.
         break
      Endif
   
      WorkIt->(dbSkip())
   Enddo 
   
End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao      : LogFat.
Parametros  : nOpc    -> Operação.
              aHeader -> Array com os campos a serem enviados da capa do processo de exportação.
              aDetail -> Array com os campos a serem enviados dos itens do processo de exportação.
              cParte  -> Parte do log que será gravada
Retorno     : .t./.f.
Objetivos   : Gerar log com detalhes do envio/gravacao no faturamento.
Autor       : Jeferson Barros Jr.
Data/Hora   : 17/02/2003 15:12.
Revisao     :
Obs.        :
*/
*------------------------------------------*
Function LogFat(nOpc,aHeader,aDetail,cParte)
*------------------------------------------*
Local lRet := .t., hFile
Local nTam:=0, i:=0, y:=0, z:=0
Local cBuffer := "", cBody := ENTER, cFile :="eecfat.log"
Local aKey:={{"EE7","EE7_PEDFAT"},{"SC5","C5_NUM"},{"SC6","C6_ITEM"},{"SC6","C6_NUM"}},;
      aIndices:={}, aFiles:={"SC5","SC6"}, aOrd:=SaveOrd("SIX")
Local cPedFat := ""
Begin Sequence

   If !File(cFile)
      hFile := EasyCreateFile(cFile)
      If ! (hFile > 0)
         EECMsg(STR0005+Replic(ENTER,2)+; //"O arquivo de log da integração com o faturamento não pode ser gerado."
                 STR0006+ENTER+; //"Detalhes:"
                 STR0007+cFile+".", STR0002, "MsgStop") //"Erro na criação do arquivo: "###"Aviso"
         lRet:=.f.
         Break
      Endif
      fClose(hFile)
   EndIf
   
   IF cParte == "1" // 1a. Parte
      Six->(DbSetOrder(1))

      // ** Informações de cabeçario.
      if Type("cCALLLOC") == "C" .and. cCALLLOC == "EE7" 
         cBody += "Processo   : "+M->EE7_PEDIDO+ENTER
      else
         cBody += "Processo   : "+M->EEC_PREEMB+ENTER
      endif
      cBody += "Data/Hora  : "+Transf(dDataBase,"  /   /  ")+" - "+Time()+ENTER

      // ** Tipo da operação.
      If nOpc = 3
         cBody += STR0008+Replic(ENTER,2) //"Operação   : Inclusão "
      ElseIf nOpc = 4
         cBody += STR0009+Replic(ENTER,2) //"Operação   : Alteração"
      Else
         cBody += STR0010+Replic(ENTER,2) //"Operação   : Exclusão "
      EndIf
 
      // ** Parametros.
      cBody += STR0011+ENTER //"Parametros"
      cBody += "----------"+ENTER
      cBody += "MV_EECFAT  : "+Transf(EasyGParam("MV_EECFAT") ,"@!")+ENTER
      cBody += "MV_EECAUTO : "+Transf(EasyGParam("MV_EECAUTO"),"@!")+Replic(ENTER,2)

      // ** Estrutura dos arquivos.
      cBody += IncSpace("Campo",10,.f.)+Space(1)+IncSpace(STR0012,15,.t.)+Space(1)+IncSpace(STR0013,15,.t.)+ENTER //"Tam.Dicionario"###"Tam.Base"
      cBody += Replic("-",10)+Space(1)+Replic("-",15)+Space(1)+Replic("-",15)+ENTER

      For i:=1 To Len(aKey)
         nTam:= Len(&(aKey[i][1]+"->"+aKey[i][2]))

         cBody += IncSpace(aKey[i][2],10,.f.)+Space(1)+IncSpace(AllTrim(Str(AVSX3(aKey[i][2],AV_TAMANHO))),15,.t.)+Space(1)+;
                  IncSpace(AllTrim(Str(nTam)),15,.t.)+ENTER
      Next

      cBody += ENTER

      // ** Informações dos Indices (Base e Sindex).
      cBody += STR0014 + ENTER //"Indices : "
      cBody += "--------- " + Replic(ENTER,2)

      For i:=1 To Len(aFiles)

         cBody += STR0015+aFiles[i]+ ENTER //"Arquivo : "

         Six->(DbSeek(aFiles[i]))
         Do While Six->(!Eof()) .And. Six->INDICE == aFiles[i]
            aAdd(aIndices,{Six->ORDEM,Six->CHAVE})
            Six->(DbSkip())
         EndDo

         If Len(aIndices) > 0
            // ** Informações dos indices na Base.
            cBody += STR0016 + ENTER //"Base"
            cBody += "----" + ENTER
            cBody += IncSpace(STR0017,6,.f.)+Space(5)+IncSpace(STR0018,150,.f.)+ENTER //"Ordem"###"Chave"

            For y:=1 To Len(aIndices)
               cBody += IncSpace(AllTrim(aIndices[y][1]),6,.f.)+Space(5)+;
                        IncSpace((aFiles[i])->(IndexKey(Val(aIndices[y][1]))),150,.f.)+ENTER
            Next

            cBody += ENTER

            // ** Informações dos indices no dicionário.
            cBody += STR0019 + ENTER //"Dicionario"
            cBody += "----" + ENTER
            cBody += IncSpace(STR0017,6,.f.)+Space(5)+IncSpace(STR0018,150,.f.)+ENTER //"Ordem"###"Chave"
    
            For z:=1 To Len(aIndices)
               cBody += IncSpace(AllTrim(aIndices[z][1]),6,.f.)+Space(5)+;
                        IncSpace(AllTrim(aIndices[z][2]),150,.f.)+ENTER
            Next

            cBody += ENTER
         EndIf

         aIndices:={}
      Next

      // ** Detalhes das informações enviadas. - Capa.
      cBody += STR0020+ENTER //"Informações Enviadas - Capa"
      cBody += Replic("-",27)+ENTER
      cBody += IncSpace(STR0021,10,.f.)+Space(5)+IncSpace(STR0022,60,.f.)+ENTER //"Campo"###"Conteudo"

      For i:=1 To Len(aHeader)
         If aHeader[i][1] <> "AUTDELETA"
            cBody += IncSpace(aHeader[i][1],10,.f.)+Space(5)+;
                     IncSpace(AllTrim(Transf(aHeader[i][2],AVSX3(aHeader[i][1],AV_PICTURE))),10,.f.)+ENTER
         Else
            cBody += IncSpace(aHeader[i][1],10,.f.)+Space(5)+;
                     IncSpace(AllTrim(Transf(aHeader[i][2],"@!")),10,.f.)+ENTER
         EndIf
      Next

      // ** Detalhes das informações enviadas. - Itens.
      If Len(aDetail) > 0
         cBody += ENTER
         cBody += STR0023+ENTER //"Informações Enviadas - Itens"
         cBody += Replic("-",29)+ENTER

         For i:=1 To Len(aDetail)
            cBody += IncSpace(STR0021,10,.f.)+Space(5)+IncSpace(STR0022,60,.f.)+ENTER //"Campo"###"Conteudo"

            For y:=1 To Len(aDetail[i])
               If aDetail[i][y][1] <> "AUTDELETA"
                  cBody += IncSpace(aDetail[i][y][1],10,.f.)+Space(5)+;
                           IncSpace(AllTrim(Transf(aDetail[i][y][2],AVSX3(aDetail[i][y][1],AV_PICTURE))),60,.f.)+ENTER
               Else
                  cBody += IncSpace(aDetail[i][y][1],10,.f.)+Space(5)+;
                           IncSpace(AllTrim(Transf(aDetail[i][y][2],"@!")),60,.f.)+ENTER
               EndIf
            Next

            cBody += ENTER
         Next
      Else
         cBody += ENTER
         cBody += STR0024+ENTER //"Não foram enviadas informações de itens."
      EndIf
   Else
      // 2a. Parte
   
      // ** Detalhes das informações gravadas. (Capa) 
      cBody += ENTER     
      cBody += STR0025+IF(lMSErroAuto,".T.",".F.")+ENTER      //"Retorno do MATA410 - lMSErroAuto : "
      cBody += ENTER     
      cBody += STR0026+ENTER //"Informações Gravadas - Capa"
      cBody += Replic("-",27)+ENTER

      if Type("cCALLLOC") == "C" .and. cCALLLOC == "EE7" 
         cPedFat := M->EE7_PEDFAT
      else
         If (nPos := aScan(aCab, {|x| x[1] == "C5_NUM"})) > 0    
            cPedFat := aCab[nPos][2]
         Else 
            cPedFat := "" 
         EndIf
      endif     
      SC5->(DbSetOrder(1))
      If SC5->(DbSeek(xFilial("SC5")+cPedFat))
         cBody += IncSpace("Campo",10,.f.)+Space(5)+IncSpace(STR0022,60,.f.)+ENTER //"Conteudo"

         For i := 1 To SC5->(FCount())
            cBody += IncSpace(AllTrim(SC5->(FieldName(i))),10,.f.)+Space(5)+;
                     IncSpace(AllTrim(Transf(SC5->(FieldGet(i)),AVSX3(SC5->(FieldName(i)),AV_PICTURE))),60,.f.)+ENTER
         Next

      Else
         cBody += STR0027+AllTrim(cPedFat)+ENTER //"Não foi encontrado nenhum registro para o pedido nro : "
      EndIf

      // ** Detalhes das informações gravadas. (Itens)
      cBody += ENTER
      cBody += STR0028+ENTER //"Informações Gravadas - Itens"
      cBody += Replic("-",28)+ENTER

      SC6->(DbSetOrder(1))
      If SC6->(DbSeek(xFilial("SC6")+cPedFat))
         Do While SC6->(!Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And.;
                                      SC6->C6_NUM    == cPedFat

            cBody += IncSpace(STR0021,10,.f.)+Space(5)+IncSpace(STR0022,60,.f.)+ENTER //"Campo"###"Conteudo"
            For i := 1 TO SC5->(FCount())
               cBody += IncSpace(AllTrim(SC6->(FieldName(i))),10,.f.)+Space(5)+;
                        IncSpace(AllTrim(Transf(SC6->(FieldGet(i)),AVSX3(SC6->(FieldName(i)),AV_PICTURE))),60,.f.)+ENTER
            Next
            cBody += ENTER

            SC6->(DbSkip())
         EndDo
      Else
         cBody += STR0029+AllTrim(cPedFat)+ENTER //"Não foi encontrado nenhum item para o pedido nro : "
      EndIf

      // ** Rodape.
      cBody += Replic(ENTER,2)+Replic("*",70)
   Endif
   
//   cErrorLog := cBody

   cBuffer:=MemoRead(cFile)
   MemoWrite(cFile,cBuffer+ENTER+cBody)

End Sequence

RestOrd(aOrd)

Return lRet
*------------------------------------------------------------------------*
* FIM DO PROGRAMA EECFAT.PRW                                             *
*------------------------------------------------------------------------*


/*
Função     : AVMata410
Parametros : aCab, aItens, nOpc
Objetivo   : Manter a integridade dos dados que serão enviados para o faturamento.
Autor      : Alexsander Martins dos Santos
Data e Hora: 23/03/2004 às 12:13.
*/

Function AVMata410(aCab, aItens, nOpc, cChamada)

Local lReturn       := .T.
Local nCont         := 1
Local nContIt       := 1
Local nPos          := 0
Local aSaveOrd      := SaveOrd({"SC5", "SC6"})
Local cItem         := "00"
Local lGeraLog      := EasyGParam("MV_EECFLOG",, .f.)
Local lDelCapa      := .F.
Local lDelItem      := .F. 
Local lRetAltPed    := .T.

Local cSC5NaoEnvia  := ""
Local cSC6NaoEnvia  := "C6_LOTECTL, C6_NUMLOTE, C6_DTVALID"

//ER - 03/10/2007 - Campos padrão que serão enviados ao Faturamento.
Local aSC5Padrao    := {"C5_NUM","C5_TIPO","C5_CLIENTE","C5_LOJACLI","C5_TIPOCLI","C5_CONDPAG",;
                        "C5_EMISSAO","C5_MOEDA","C5_PESOL","C5_PBRUTO","C5_PEDEXP"}
Local aSC6Padrao    := {"C6_NUM","C6_ITEM","C6_PRODUTO","C6_UM","C6_QTDVEN","C6_PRCVEN","C6_PRUNIT",;
                        "C6_TES","C6_CF","C6_VALDESC","C6_LOCAL","C6_ENTREG","C6_DESCRI"}
                        
Local nItem, nC6_ITEM ,nC5_NUM // RMD - 14/02/2014

Local cErro := ""

Private lMSErroAuto := .F.
Private lMSHelpAuto := .F.

Default cChamada    := "PED"

If EE8->(FieldPos("EE8_OPER")) > 0   
   aAdd(aSC6Padrao, "C6_OPER")  
   aAdd(aSC6Padrao, "AUTDELETA")   
Else
   aAdd(aSC6Padrao, "AUTDELETA")   
EndIf

Begin Sequence
   Do Case

      Case nOpc = 3 //Inclusão

         While nCont <= Len(aCab)
         
            //ER - 30/01/2008 - Na inclusão, caso o parâmetro MV_EECAUTO (Define se o número do Pedido de Venda será
            //                  igual ao número do Pedido de Exportação.) seja .F., o campo C5_NUM não deverá ser enviado
            //                  para o Faturamento. A função MATA110() irá gerar esse número que será posteriormente gravado
            //                  no campo EE7_PEDFAT.  
            If AllTrim(aCab[nCont][1]) == "C5_NUM" 
               If Empty(aCab[nCont][2])
                  aDel(aCab, nCont)
                  aCab := aSize(aCab, Len(aCab)-1)
               EndIf
            EndIf
 
            //ER - 30/01/2008 - Se o campo pertencer ao array aSC5Padrao, sempre será enviado ao Faturamento.
            If aScan(aSC5Padrao,Alltrim(aCab[nCont][1])) == 0
    
               //Se o conteudo do campo estiver vazio ou o campo estiver no
               //parâmetro MV_AVG0073, não será enviado para o Faturamento.
               If Empty(aCab[nCont][2]) .or. (aCab[nCont][1] $ EasyGParam("MV_AVG0073",, cSC5NaoEnvia))
                  aDel(aCab, nCont)
                  aCab := aSize(aCab, Len(aCab)-1)
               Else
                  nCont++
               EndIf
 
            Else
               nCont++
            EndIf
   
         EndDo
      
         For nCont := 1 To Len(aItens)         

            While nContIt <= Len(aItens[nCont])
            
               //ER - 30/01/2008 - Se o campo pertencer ao array aSC6Padrao, sempre será enviado ao Faturamento.
               If aScan(aSC6Padrao,Alltrim(aItens[nCont][nContIt][1])) == 0

                  //Se o conteudo do campo estiver vazio ou o campo estiver no
                  //parâmetro MV_AVG0074, não será enviado para o Faturamento.
                  If Empty(aItens[nCont][nContIt][2]) .or. (aItens[nCont][nContIt][1] $ EasyGParam("MV_AVG0074",, cSC6NaoEnvia))
                     aDel(aItens[nCont], nContIt)
                     aItens[nCont] := aSize(aItens[nCont], Len(aItens[nCont])-1)
                  Else
                     nContIt++
                  EndIf
               Else
                  nContIt++
               EndIf
            EndDo

            nContIt := 1
         Next

      Case nOpc = 4 //Alteração
      
         //DFS - 02/04/13 - Chamada da função para verificar se houve alguma alteração ou não no Pedido de Exportação.    	                    
    	 //LRS - 04/12/2013 - Validação reativada, colocando outra validação para somente pedido de exportação já faturando entrarem na função
    	 dbSelectArea("SC5")
    	 /* Nopado por GFP - 24/10/2014
    	 If (SC5->(dbSeek(xFilial("SC5") + M->EE7_PEDFAT)))
    	 	If !Empty(SC5->C5_NOTA)
         	   //If !FAT2ALTPED(cChamada) //LRS Foi Dopado a chamada da função
            	lRetAltPed := .F.
            	Break
           	   //EndIf //LRS
         	EndIf
         EndIf
         */
         /*
            Caso não exista Pedido de Venda, é gravado um Novo Pedido de Venda na Alteração do
            Pedido de Exportação.      
         */
         If cChamada == "PED"
            If EE7->(FieldPos("EE7_GPV")) > 0 .And. (M->EE7_GPV $ cNao) .And. !Empty(M->EE7_PEDFAT)
               SC5->(dbSetOrder(1))
               If SC5->(dbSeek(xFilial("SC5") + M->EE7_PEDFAT))
                  lReturn := MC110Integra(5,"GRV")
                  Break
               EndIf
            EndIf
         Else
            If EEC->(FieldPos("EEC_GPV")) > 0 .And. (M->EEC_GPV $ cNao) .And. !Empty(M->EEC_PEDFAT)
               SC5->(dbSetOrder(1))
               If SC5->(dbSeek(xFilial("SC5") + M->EEC_PEDFAT))
                  lReturn := FAT3EmbGerPV(5,"GRV")
                  Break
               EndIf
            EndIf
         EndIf
      
         SC5->(dbSetOrder(1))
         SC6->(dbSetOrder(1)) //C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO

         If (nPos := aScan(aCab, {|x| x[1] == "C5_NUM"})) > 0

            If SC5->(dbSeek(xFilial("SC5") + aCab[nPos][2]))
              
               //Verifica todos os campos de capa que serão enviados ao Faturamento, para tratar campos
               //que não deverão ser enviados.
               While nCont <= Len(aCab)
               
                  //ER - 30/01/2008 - Se o campo pertencer ao array aSC5Padrao, sempre será enviado ao Faturamento.
                  If aScan(aSC5Padrao,Alltrim(aCab[nCont][1])) == 0
                  
                     lDelCapa := .F.

                     //ER - 03/10/2007 - Se o campo não existir na tabela SC5 (Capa do Pedido de Venda) ou estiver no
                     //                  parâmetro MV_AVG0073, não será enviado para o Faturamento.
                     If SC5->(FieldPos(aCab[nCont][1])) == 0 .or. aCab[nCont][1] $ EasyGParam("MV_AVG0073",, cSC5NaoEnvia)
                        lDelCapa := .T.
                     EndIf
               
                     //ER - 30/01/2008 - Retira o campo do array aCab.
                     If lDelCapa
                        aDel(aCab, nCont)
                        aCab := aSize(aCab, Len(aCab)-1) 
                     Else
                        nCont++ 
                     EndIf
               
                  Else
                     nCont++
                  EndIf
               EndDo
            
               //Loop em todos os itens do Pedido de Exportação que será integrado ao faturamento.
               For nCont := 1 To Len(aItens)

                  If aScan(aItens[nCont], {|x| x[1] == "AUTDELETA" .and. x[2] == "S"}) = 0 //AMS - 16/10/2004 às 17:15.

                     //Verifica se o campo C6_ITEM está presente no array com os campos de itens a serem integradros ao Faturamento.
                     If (nPos := aScan(aItens[nCont], { |x| x[1] == "C6_ITEM" })) > 0
                  
                        If SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM + aItens[nCont][nPos][2]))
                        
                           //Verifica todos os campos de itens que serão enviados ao Faturamento, para tratar campos
                           //que não deverão ser enviados.
                           While nContIt <= Len(aItens[nCont])
                           
                              lDelItem := .F.

                              //ER - 30/01/2008 - Se o campo pertencer ao array aSC6Padrao, sempre será enviado ao Faturamento.
                              If aScan(aSC6Padrao,Alltrim(aItens[nCont][nContIt][1])) == 0
       
                                 //ER - 03/10/2007 - Se o campo não existir na tabela SC6 (Itens do Pedido de Venda) ou estiver no
                                 //                  parâmetro MV_AVG0074, não será enviado para o Faturamento.
                                  If SC6->(FieldPos(aItens[nCont][nContIt][1])) == 0 .or. aItens[nCont][nContIt][1] $ EasyGParam("MV_AVG0074",, cSC6NaoEnvia)
                                    lDelItem := .T.
                                  EndIf
   
                                  //ER - 30/01/2008 - Retira o campo do array aItens.
                                 If lDelItem
                                    aDel(aItens[nCont], nContIt)
                                    aItens[nCont] := aSize(aItens[nCont], Len(aItens[nCont])-1)
                                 Else
                                    nContIt++                                 
                                 EndIf
                              Else
                                 nContIt++
                              EndIf
                           EndDo
 
                           nContIt := 1
                        EndIf

                     Else
                        EECMsg(STR0030, ,"MsgStop") //"O Campo C6_ITEM não foi encontrado no array aItens, pela função AVMata410. O processo não será integrado com faturamento."
                        lReturn := .F.
                     EndIf

                  EndIf

               Next

            Else
            
               /*
               Caso o pedido do EASY(EE7) que está sendo alterado não esteja no Faturamento(SC5) e os 
               itens não estejam no SC6 é feita a inclusão automática do pedido no faturamento.
               */

               For nCont := 1 To Len(aItens)
                  If (nPos := aScan(aItens[nCont], { |x| x[1] == "C6_ITEM" })) > 0
                     If SC6->(dbSeek(xFilial("SC6") + aCab[1][2] + aItens[nCont][nPos][2]))
                        lReturn := .F.
                        Break
                     EndIf
                  EndIf
               Next
            
               If lReturn                           
                  //Grava no aCab e aItens os campos para integração no faturamento.
                  aCab[1][2] := GetSXENum("SC5")
                  ConfirmSx8()  // JPP - 03/07/2006 - 09:30 - Atualizar a numeração automática definida pela função GetSXENum("SC5").
               
                  For nCont := 1 To Len(aItens)
                     aItens[nCont][1][2] := aCab[1][2]
                     aItens[nCont][2][2] := (cItem := SomaIt(cItem))
                  Next
               
                  AVMata410( aCab, aItens, 3 )
               Else               
                  EECMsg(STR0031,,"MsgStop") //"Foi encontrado incompatibilidade entre o SC5 e SC6, tendo informações sobre os itens e não da capa! O processo não será integrado com o faturamento."
                  lReturn := .F.
               EndIf
         
            EndIf

         Else      
            EECMsg(STR0032,,"MsgStop") //"O campo C5_NUM não foi encontrado no array aCab, pela função AVMata410. O processo não será integrado com faturamento."
            lReturn := .F.      
         EndIf

   EndCase
   
   //DFS - 02/04/13 - Força a verificação, para sair da função. 
   If !lRetAltPed
      Break
   EndIf

   If lReturn

      If lGeraLog
         LogFat(nOpc, aCab, aItens, "1")
      EndIf

      If cChamada == "PED"
         If nOpc == 3 .And. aCab[1][1] == "C5_NUM"
            M->EE7_PEDFAT := aCab[1][2]
         Endif
      Else
         If nOpc == 3 .And. aCab[1][1] == "C5_NUM"
            M->EEC_PEDFAT := aCab[1][2]
         Endif
      EndIf

   
      aCabBkp := aClone(aCab)  // DFS - 23/11/2012
      //LRS - 08/01/2016 - Correção da validação do campo LINPOS para a integração correta
      //*** RMD - 14/02/14 - Ajusta o array dos itens para informar o item atual a partir da variável LINPOS quando alteração ou exclusão
      If nOpc == ALTERAR .Or. nOpc == EXCLUIR
	      For nItem := 1 To Len(aItens)
	         If (nC6_ITEM := aScan(aItens[nItem], {|x| AllTrim(x[1]) == "C6_ITEM" })) > 0 .And. (nC5_NUM := aScan(aCab, {|x| AllTrim(x[1]) == "C5_NUM" })) > 0
		         If SC6->(dbSeek(xFilial("SC6") + aCab[nC5_NUM][2] + aItens[nItem][nC6_ITEM][2]))
		         	aItens[nItem][nC6_ITEM] := {"LINPOS", "C6_ITEM", aItens[nItem][nC6_ITEM][2]}
		         EndIf
	         EndIF
	      Next
	  EndIf
      //***
   
      MsExecAuto({|x,y,z| mata410(x,y,z)},aCab, aItens, nOpc)
   
      aCab := aClone(aCabBkp)  // DFS - 23/11/2012
   
      If lMSErroAuto
      
         /* 
         	RMD - 16/01/15 - Novo tratamento para considerar as parametrizações do módulo de faturamento definidas no parâmetro
         	MV_ALTPED. Este parâmetro não permite alterações no Pedido de Venda após o seu faturamento completo.
         	Como a integração com o Faturamento sempre é executada ao salvar o Pedido de Exportação, se o Pedido de Venda estiver faturado 
         	a integração retornará mensagem informando que o PV não pode ser alterado e a gravação do Pedido de Exportação é abortada.
         	Para que isso não impeça a operação do sistema, quando esta mensagem for retornada verificaremos se foi solicitada a alteração
         	alguma informação chave do Pedido de Venda, e caso não tenha, a mensagem será ignorada e a gravação confirmada.
         */
         
         //MostraErro()
         If ValType(NomeAutoLog()) == "C" .And. !Empty(MemoRead(NomeAutoLog()))
            cErro := MemoRead(NomeAutoLog())
            FErase(NomeAutoLog())
            __cFileLog := Nil
         Else
            cErro := " "
         EndIf
         cRet := FAT2AltPed("PED") //LRS - 26/02/2015
         
         If (!At("A410PEDFAT", cErro) > 0 .Or. !Empty(cRet))
         	If Type("lEE7AUTO") <> "L" .Or. !lEE7Auto
               EECView(cRet + ENTER + ENTER + cErro, "Não foi possível integrar com o módulo de Faturamento.")
            Else
               EasyHelp(cRet + "(" + cErro + ")", "EECFAT2")
            EndIf
            lReturn := .F.
         EndIf
         
         //DFS - 06/06/13 - Nopado a chamada da variavel, visto que, não estava declarada e não seria mais utilizada neste ponto.
         /*If lGrade
            //&(MaReadGrd()):cObj:= "oGrdExp"
            //Ap102GrdMonta()
         EndIf */
      EndIf

      If !lMSErroAuto .and. nOpc == 3       
         IF aCab[1][1] == "C5_NUM"
            If !SC5->(dbSeek(xFilial("SC5")+aCab[1][2]))
               lReturn := .F. 
            Endif
         Endif
      EndIf    
   
      If !lMSErroAuto .and. (nOpc == INCLUIR .or.nOpc == ALTERAR)
         If cChamada == "PED"
            //Grava Número no Faturamento
            If Empty(M->EE7_PEDFAT)
               M->EE7_PEDFAT := SC5->C5_NUM
            EndIf
         Else
            //Grava Número no Faturamento
            If Empty(M->EEC_PEDFAT)
               M->EEC_PEDFAT := SC5->C5_NUM
            EndIf
         EndIf
      EndIf
   
      If lGeraLog
         If LogFat(nOpc, aCab, aItens, "2")
            If !(Type("lSched") == "L" .And. lSched) .And. !EECMsg(STR0033+Replic(ENTER,2)+; //"Log com os detalhes da integração gerado com sucesso!"
                         STR0034, STR0002, "MsgYesNo") //"Deseja deixar ativa a geração de log para a integração?"###"Aviso"
               SetMv("MV_EECFLOG", .f.)
            EndIf
         EndIf
      EndIf

   EndIf    
End Sequence

RestOrd(aSaveOrd)

Return(lReturn)


/*
Função UNSpace
Objetivo   : Remover espaços em brancos do conteúdo passado como parametro.
             Se o parametro passado for diferente de caracter, será retorna o mesmo valor.
Autor      : Alexsander Martins dos Santos
Data e Hora: 06/08/2004 às 11:31.
Observação : Nopado por Eduardo Romanini. 30/01/2008 às 15:30.
             A função não é mais utilizada no Fonte.
*/
/*
Static Function UNSpace(cParametro)

If ValType(cParametro) = "C"
   cParametro := AllTrim(cParametro)
EndIf

Return(cParametro)
*/
/*
Funcao      : AE100PosItSD2(cPedido,cSequen,cNota,cSerie)
Parametros  : cPedido := Nro do Processo de Exportacao (EE7)
              cSequen := Nro da Sequencia (EE8)
Retorno     : .T. se achou o item 
              .F. se nao achou o item
Objetivos   : Posicionar no item da nota fiscal do SIGAFAT
Autor       : Alex Wallauer (AWR)
Data/Hora   : 30/09/2005 12:00
Revisao     :
Obs.        :
*/
Function AE100PosItSD2(cPedido,cSequen,cNota,cSerie)

Local cPedFat, cFatIt, cFilSD2:=xFilial("SD2"), lAchou:=.F.

Begin Sequence
   
   // Identificacao do Pedido no SIGAFAT
   cPedFat := Posicione("EE7",1,xFilial("EE7")+cPedido,"EE7_PEDFAT")
   // Identificacao do Item do Pedido no SIGAFAT
   cFatIt  := Posicione("EE8",1,xFilial("EE8")+cPedido+cSequen,"EE8_FATIT")
   
   cPedFat := AvKey(cPedFat,"D2_PEDIDO")
   cFatIt  := AvKey(cFatIt ,"D2_ITEMPV")
   
   SD2->(dbSetOrder(3)) // FILIAL+DOC+SERIE+...
   SD2->(dbSeek(cFilSD2+cNota+cSerie))
   
   DO While SD2->(!Eof() .And. D2_FILIAL == cFilSD2 .And. D2_DOC+D2_SERIE == cNota+cSerie)
      
      IF SD2->(D2_PEDIDO+D2_ITEMPV) == cPedFat+cFatIt
         lAchou:=.T.
         EXIT
      Endif
      
      SD2->(dbSkip())
   Enddo
      
End Sequence

Return lAchou

/*
Função     : SeqItem
Parametros : cItem
Objetivo   : Obter o número do item a ser incluído no pedido do faturamento.
Autor      : Rodrigo Mendes Diaz
Data e Hora: 10/08/05 16:30
*/

Static Function SeqItem(cItem)

Local aOrd     := SaveOrd({"WorkIt"})
Local aAreaEE8 := EE8->(getArea())
Local w

   WorkIt->(DbSetOrder(1))
   WorkIt->(dbGoBottom()) 

   While WorkIt->EE8_RECNO == 0 .And. WorkIt->(!Bof())
      WorkIt->(DbSkip(-1))
   End

   If WorkIt->EE8_FATIT > cItem
      cItem := WorkIt->EE8_FATIT
   EndIf

   if len(aDeletados) > 0
      for w := 1 to len(aDeletados)
         EE8->(dbgoto(aDeletados[w]))
         if EE8->EE8_FATIT > cItem
            cItem := EE8->EE8_FATIT
         endif
      next
   endif

   cItem := SomaIt(cItem)
   RestOrd(aOrd)
   restArea(aAreaEE8)
   
Return (cItem)

/*
Funcao      : Fat2ApTot()
Parametros  : Nenhum
Retorno     : Total do Pedido
Objetivos   : Retorna o total do pedido de acordo com os itens. usada quando o tratamento de 
              commodities está ativo.
Autor       : Fabio Justo Hildebrand - FJH
Data/Hora   : 10/11/05 15:44
Obs.        : Uma fórmula qua chama essa função deve ser cadastrada no eecfat e seu código
              gravado no parametro MV_AVG0111
*/

Function FAT2ApTot()
Local aOrd:=SaveOrd("EE8", 1), nRet:=0

IF EE8->(DBSEEK(xFilial("EE8")+SC5->C5_PEDEXP))
   While EE8->(!EOF()) .and. EE8->EE8_FILIAL == xFilial("EE8") .and. EE8->EE8_PEDIDO == SC5->C5_PEDEXP
      nRet += EE8->EE8_PRCTOT
      EE8->(DBSkip())
   End
Endif

RestOrd(aOrd)
Return nRet

/*
Funcao      : AvChkStDesp
Parametros  : cPedFat - Número do Pedido de Venda
Retorno     : .T. - Caso o Pedido de Venda possa ser liberado.
              .F. - Caso o Pedido de Venda não possa ser liberado
Objetivos   : Não permite a liberação de Pedidos de Venda Filhos (Relacionados ao Pedido de Venda).              
Autor       : Eduardo C. Romanini
Data/Hora   : 14/01/2008 12:00
Obs.        : Essa função é chamado pelo módulo faturamento da Microsiga na
              liberação manual do Pedido de Venda.
*/
*---------------------------*
Function AvChkStDesp(cPedFat)
*---------------------------*
Local lRet  := .T.
Local lMsg  := .F.

Local cFase     := ""
Local cPedExp   := ""

Local nPos := 0
Local nInc := 0

Local aEmbarque := {}                    //NCF - 27/01/2011 - Alteração na atribuição

Private lIntDesp := EECFLAGS("INTEMB")
Private lPE_Msg := .F.

Begin Sequence
   
   If !lIntDesp
      Break
   EndIf
   
   cFase := FatFasePV(cPedFat)
   
   If cFase <> OC_EM
      
      ////////////////////////////////////////////////////////////////////////
      //Caso o Pedido de Venda esteja relacionado a um Pedido de Exportação,//
      //deverá ser verificado se será gerada a nova ou antiga Integração    //
      //com o Faturamento                                                   //
      ////////////////////////////////////////////////////////////////////////
      SC5->(DbSetOrder(1))
      If SC5->(DbSeek(xFilial("SC5")+AvKey(cPedFat,"C5_NUM")))
         cPedExp := SC5->C5_PEDEXP
      EndIf
      
      ////////////////////////////////////////////////////////////////////////////////////
      //Verifica se existe algum embarque gerado para o Pesido de Exportação relacionado//
      ////////////////////////////////////////////////////////////////////////////////////
      EE9->(DbSetOrder(1))
      If !Empty(cPedExp) .and. EE9->(DbSeek(xFilial("EE9")+AvKey(cPedExp,"EE9_PEDIDO")))
         While EE9->(!EOF()) .and. EE9->(EE9_FILIAL+EE9_PEDIDO) == xFilial("EE9")+AvKey(cPedExp,"EE9_PEDIDO")
            
            nPos := aScan(aEmbarque,EE9->EE9_PREEMB)
            
            If nPos == 0                             //NCF - 27/01/2011 - Alteração na comparação
               aAdd(aEmbarque,EE9->EE9_PREEMB)
            EndIf
               
            EE9->(DbSkip())
         EndDo
      Else
         //////////////////////////////////////////////////////////////////////////////////
         //Caso o Pedido não faça parte de nenhum embarque, a mensagem deverá ser exibida//
         //////////////////////////////////////////////////////////////////////////////////      
         lMsg := .T.
      EndIf
      
      ///////////////////////////////////////////////////////////////////////////
      //Caso algum dos Embaques foi gerado com a nova integração do Faturamento//
      //a Mensagem será exibida.                                               //
      ///////////////////////////////////////////////////////////////////////////
      For nInc:=1 To Len(aEmbarque)  
         If FAT3IntFat(aEmbarque[nInc],ALTERAR)
            lMsg := .T.
         EndIf
      Next
      
      /////////////////////////////////////////////////
      //Ponto de Entrada para validações customizadas//
      /////////////////////////////////////////////////
      If EasyEntryPoint("EECFAT2")
         lPE_Msg := lMsg
         ExecBlock("EECFAT2",.F.,.F.,{"LIB_PEDFAT",cPedExp})
         lMsg := lPE_Msg
      Endif

      ////////////////////////////////////////////////////////////////
      //Exibe a mensagem de bloqueio da liberação do Pedido de Venda//
      ////////////////////////////////////////////////////////////////
      If lMsg
         Help(" ",1,"AVG0005372")
         lRet := .F.
      EndIf

   EndIf

End Sequence

Return lRet

/*
Funcao      : FatFasePV()
Parametros  : cPedFat - Número do Pedido de Venda
Retorno     : cRet: OC_PE - Fase de Pedido
                    OC-EM - Fase de Embarque
Objetivos   : Indica a qual fase (Pedido ou Embarque) o Pedido de Venda está relacionado.
Autor       : Eduardo C. Romanini
Data/Hora   : 06/06/2008 17:00
Obs.        : 
*/
*---------------------------*
Function FatFasePV(cPedFat)
*---------------------------*
Local cRet := ""
Local cPedExp    := ""

Local aSemSX3    := {}

#IFDEF TOP
   Local cQrY := ""
#ENDIF
Private aHeader  := {}
Private aCampos  := {}

Begin Sequence
   cPedExp := ""
   aSemSX3 := {}
   
   #IFDEF TOP  

      cQry := "Select '" + OC_PE + "' as FASE From " + RetSQLName("EE7")
      cQry += " Where EE7_PEDFAT In (Select C5_NUM From " + RetSQLName("SC5") + " Where C5_NUM = '" + cPedFat + "' and D_E_L_E_T_ <> '*')"
      
      cQry += " Union "
      
      cQry += "Select '" + OC_EM + "' as FASE From " + RetSQLName("EEC")
      cQry += " Where EEC_PEDFAT In (Select C5_NUM From " + RetSQLName("SC5") + " Where C5_NUM = '" + cPedFat + "' and D_E_L_E_T_ <> '*')" 

      //WFS 02/07/09
      ChkFile("EXD")
      If Select("EXD") > 0
         cQry += " Union "
      
         cQry += "Select '" + OC_EM + "' as FASE From " + RetSQLName("EXD")
         cQry += " Where EXD_PEDFAT In (Select C5_NUM From " + RetSQLName("SC5") + " Where C5_NUM = '" + cPedFat + "' and D_E_L_E_T_ <> '*')" 
      EndIf
  
      cQry := ChangeQuery(cQry)
      
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "QRY", .F., .T.)
   
   #ELSE

      aAdd(aSemSX3,{"FASE", "C", 1, 0})
      
      cNomArq := E_CriaTrab(,aSemSX3,"QRY")
      IndRegua("QRY",cNomArq+TEOrdBagExt(),"FASE")

      SC5->(DbSetOrder(1))
      If SC5->(DbSeek(xFilial("SC5")+AvKey(cPedFat,"C5_NUM")))
         cPedExp := SC5->C5_PEDEXP
      EndIf

      EE7->(DbSetOrder(1))
      If EE7->(DbSeek(xFilial("EE7")+Avkey(cPedExp,"EE7_PEDIDO")))
         If AllTrim(EE7->EE7_PEDFAT) == AllTrim(cPedFat)
            QRY->(DbAppend())
            QRY->FASE := OC_PE
         EndIf
      EndIf
      
      EEC->(DbSetOrder(1))
      If EEC->(DbSeek(xFilial("EEC")+AVKey(cPedExp,"EEC_PREEMB")))
         If AllTrim(EEC->EEC_PEDFAT) == AllTrim(cPedFat)
            QRY->(DbAppend())
            QRY->FASE := OC_EM
         EndIf
      EndIf
      
      //WFS 02/07/09
      ChkFile("EXD")
      If Select("EXD") > 0
         EXD->(DBSetOrder(1))
         If EXD->(DBSeek(xFilial() + AVKey(cPedExp, "EXD_PREEMB")))
            If AllTrim(EXD->EXD_PEDFAT) == AllTrim(cPedFat)
               QRY->(DBAppend())
               QRY->FASE:= OC_EM
            EndIf
         EndIf
      EndIf
      
      QRY->(DbGoTop())

   #ENDIF
   
   cRet := AllTrim(QRY->FASE)
   
   QRY->(DbCloseArea())

End Sequence

Return cRet

/*
Funcao      : IsFaturado
Parametros  : cProces := Número do Processo de Exportação.
              cItem   := Item do Processo de Exportação.
Retorno     : .T. - O Item está totalmente faturado
              .F. - O Item não foi faturado
Objetivos   : Verifica se o Item do Processo de Exportação foi ou não faturado no módulo SigaFAT(Possui NF).
Autor       : Eduardo C. Romanini
Data/Hora   : 22/07/2008 09:20
Obs.        : 
*/
*------------------------------------------*
Function IsFaturado(cProces,cItem, lTotFat)
*------------------------------------------*
Local lRet    := .F.

Local cPedFat := ""
Local cItFat  := ""
Local nQuant  := 0

Local aOrd    := SaveOrd({"EE7","SD2"})
Private lPeRet := .T. //LRS - 30/10/2017
Default lTotFat := .F.

Begin Sequence

  ////////////////////////////////////////////////////
  //Verifica se não está integrado com o Faturamento//
  ////////////////////////////////////////////////////
  If !EasyGParam("MV_EECFAT",.F.,.F.)
     Break
  EndIf
  
  ///////////////////////////////////////////////////////////////////
  //Verifica se os parametros da função foram passados corretamente//
  ///////////////////////////////////////////////////////////////////
  If Empty(cProces) .or. Empty(cItem)
     Break
  EndIf

  /////////////////////////////////////
  //Obtem o número do Pedido de Venda//
  /////////////////////////////////////
  EE7->(DbSetOrder(1))
  If EE7->(DbSeek(xFilial("EE7")+AvKey(cProces,"EE7_PEDIDO")))
     cPedFat := EE7->EE7_PEDFAT
  EndIf

  ////////////////////////////////////////////
  //Obtem a sequencia do item no Faturamento//
  ////////////////////////////////////////////
  EE8->(DbSetOrder(1))
  If EE8->(DbSeek(xFilial("EE8")+AvKey(cProces,"EE8_PEDIDO")+AvKey(cItem,"EE8_SEQUEN")))
     cItFat := EE8->EE8_FATIT
  EndIf
  
  //////////////////////////////////
  //Verifica se existe nota fiscal//
  //////////////////////////////////
  If !Empty(cPedFat) .and. !Empty(cItFat)
     SD2->(DbSetOrder(8))
     If SD2->(DbSeek(xFilial("SD2")+AvKey(cPedFat,"D2_PEDIDO")+AvKey(cItFat,"D2_ITEMPV")))
        If !lTotFat
           lRet := .T.
           Break
        Else      
           //DFS - 15/04/11 - Tratamento para bloqueio de campo quantidade somente quando estiver totalmente faturado
           While SD2->(!EOF()) .AND. SD2->D2_FILIAL == xFilial("SD2") .AND. SD2->D2_ITEMPV == cItFat .AND. SD2->D2_PEDIDO == cPedFat
              nQuant += SD2->D2_QUANT
              SD2->(DbSkip())
           EndDo
           If nQuant == EE8->EE8_SLDINI
              lRet := .T.
           EndIf
        EndIf
     EndIf
  EndIf

IF(EasyEntryPoint("EECFAT2"),ExecBlock("EECFAT2",.F.,.F.,"VALID_FATU"),) //LRS - 30/10/2017
IF !lPeRet
   lRet := .F.
EndIF

End Sequence

RestOrd(aOrd,.T.)

Return lRet


/*
Funcao      : Fat2SegUnidade
Parametros  : cUnidade
              nQuantidade
              nPreco
              nSaldo
Retorno     : 
Objetivos   : Converter da segunda para a primeira unidade de medida, com base no
              cadastro de produtos (SB1)
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 27/05/2010
Obs.        : 1. Os parâmetro devem ser enviado por referência
              2. A tabela SB1 deve estar posicionada no registro
Revisão     :
*/

Function Fat2SegUnidade(cUnidade, nQuantidade, nPreco, nSaldo)
Default cUnidade:= ""
Default nQuantidade:= 0,;
        nPreco     := 0,;
        nSaldo     := 0

Begin Sequence

   If SB1->B1_CONV == 0
      Break
   EndIf

   cUnidade  := SB1->B1_UM

   //Será realizado a operação inversa para a conversão da quantidade
   //MFR 08/01/2021 OSSME-5490
   If (SB1->B1_TIPCONV == "M")  // GFP - 29/11/2012
      nQuantidade:= nQuantidade / SB1->B1_CONV
      nSaldo     := nSaldo / SB1->B1_CONV
      If SB1->B1_UM <> If(Select("WorkIt")> 0, WorkIt->EE8_UNPRC, WorkIp->EE9_UNPRC)   //TRP - 12/12/2011 - Considerar a WorkIp quando fluxo alternativo.        
         nPreco     := Round(nPreco * SB1->B1_CONV, AvSx3("C6_PRCVEN", AV_DECIMAL))
      EndIf
   Else
      nQuantidade:= nQuantidade * SB1->B1_CONV
      nSaldo     := nSaldo * SB1->B1_CONV
      If SB1->B1_UM <> If(Select("WorkIt")> 0, WorkIt->EE8_UNPRC, WorkIp->EE9_UNPRC)      
         nPreco     := Round(nPreco / SB1->B1_CONV, AvSx3("C6_PRCVEN", AV_DECIMAL))
      EndIf   
   EndIf

End Sequence
Return Nil


/*
Funcao      : ValidFrtSeg
Parametros  : 
Objetivos   : Integrar os campos Frete(EE7_FRPREV) e Seguro(EE7_SEGPRE) para o pedido de venda do 
              Faturamento quando os Incoterms forem classificados como:  (CFR , CPT, CIP, DAF e DDP)
              e quando o porto for "Uruguaiana-RS" Rodoviário de acordo com o comunicado Uruguaiana, 30/06/2010.
              COMUNICADO PSR/URA Nº 0002/2010D. 
Autor       : Allan Oliveira Monteiro
Data/Hora   : 27/08/2010
Obs.        : 
Revisão     : DFS - 23/10/2010 - Atualizado conforme Decisão Disit nº 93, da 10ª RF, de 28/05/99, DOU de 30/07/99.   
              Referência http://www.aduaneiras.com.br/perguntas_respostas/default.asp?blnresposta=1&perguntaid=109&areaid=2&n=4
Retorno     : Nil 
*/

Function ValidFrtSeg()  
//Local Incoterms := "CFR , CPT, CIP, DAF e DDP"
Local cDestEE7 := "" //, cDestino := "UGA" //Uruguaiana-RS
 
//Recebendo a sigla do Porto de acordo com o destino no Pedido de Exp.
cDestEE7:= Posicione("SY9",2,xFilial("SY9")+M->EE7_DEST,"Y9_SIGLA")

//Verificando os Incoterms e o Porto
//If  M->EE7_INCOTE $ Incoterms// .And. AllTrim(cDestEE7) == AllTrim(cDestino  
   
   If EasyGParam("MV_EEC0039",,.F.) .And. EE7->(FieldPos("EE7_FREEMB")) > 0 .And. FindFunction("EasyRateio")
      aAdd(aCab,{"C5_FRETE" ,M->EE7_FRPREV+M->EE7_FRPCOM+M->EE7_FREEMB,nil}) 
   Else
      aAdd(aCab,{"C5_FRETE" ,M->EE7_FRPREV+M->EE7_FRPCOM,nil}) 
   EndIf
   
   aAdd(aCab,{"C5_SEGURO",M->EE7_SEGPRE,nil})     
   //DFS - 27/05/11 - Inclusão de carregamento de informação de Despesa Adicional.               
   aAdd(aCab,{"C5_DESPESA",M->EE7_DESPIN,nil}) //Valor de Despesas Adicionais
//EndIf

Return Nil      


/*
Funcao      : FAT2AltVlr
Objetivos   : Tratamento para trazer todos os campos que estão como usados no dicionário de dados
Autor       : DFS - Diogo Felipe dos Santos
Data/Hora   : 05/02/11 - 16:51 
Retorno     : aAltVlr 
*/

Function FAT2AltVlr()

Local aAltVlr  := {"C6_OP","C6_NUMOP","C6_ITEMOP","C6_BLQ"}
Local aNaoEnvia:= {"C6_VALOR", "C6_DESCONT"}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SC6")

While !EOF() .And. (X3_ARQUIVO == "SC6")
   If X3USO(X3_USADO) .And. X3_CONTEXT <> "V" .And. AScan(aNaoEnvia, AllTrim(X3_CAMPO)) == 0
      AADD(aAltVlr, AllTrim(X3_CAMPO))
   EndIF
   DbSkip()
EndDO                                   

Return aAltVlr

/*
Funcao      : FAT2AltPed
Objetivos   : Tratamento para verificar se houve alteração em algum conteúdo depois da inclusão do Pedido de Exportação integrado com Faturamento
Autor       : DFS - Diogo Felipe dos Santos
Data/Hora   : 01/04/13 - 16:52 
Retorno     : lAltPedExp 
*/

//RMD - 16/01/15 - Retornei a função (será utilizada em outro contexto).
Function FAT2AltPed(cChamada)  
Local i, j //FSY - 12/09/2013 - chamado 102851
Local cPedVen
Local cItCpoDiv := "C6_ENTREG"//RMD - 27/01/15 - Campos que poderão ser preenchidos no momento da emissão da NF e não são atualizados no Pedido.
Local cMensagem := cCapa := cItem := ""
Local bConv := {|x| If(ValType(x)=="N", AlLTrim(Str(x)), If(ValType(x)=="D", DToc(x), AllTrim(x))) }
Local cSeq, nPosItem

If Type("lIntEmb") == "U"  // LRS - 23/03/2016
	Private lIntEmb := EECFlags("INTEMB")
EndIf
Begin Sequence

	SC5->(dbSetOrder(1))
	SC6->(dbSetOrder(1)) 
     
	//FDR - 17/04/2013 - Verifica se o pedido de venda foi gerado pelo Embarque ou Pedido
	If lIntEmb .And. cChamada <> "PED"
	   cPedVen := M->EEC_PEDFAT
	Else
	   cPedVen := M->EE7_PEDFAT
	EndIf
	
	If Empty(cPedVen)
		Break
	EndIf

	If SC5->(DbSeek(xFilial("SC5")+cPedVen))
	   For i:=1 To Len(aCab)
	      If SC5->(FieldPos(aCab[i][1])) > 0 .And. aCab[i][2] <> SC5->&(aCab[i][1])
	         cCampo := "Não foi atualizado o campo: 'XXX' com o conteúdo 'YYY'."
	         cCampo := StrTran(cCampo, "XXX", AllTrim(aCab[i][1]))
	         cCampo := StrTran(cCampo, "YYY", Eval(bConv, aCab[i][2]))
	         cCapa += cCampo + ENTER
	      EndIf
	   Next
	   If Len(cCapa) > 0
		  cMensagem += "Não foi possível integrar com o Pedido de Venda:" + ENTER
		  cMensagem += cCapa + ENTER + ENTER
	   EndIf
	   For i:=1 To Len(aItens)
          cItem := ""
	      If (nPos := aScan(aItens[i], {|x| x[1] == "AUTDELETA" })) > 0 .And. aItens[i][nPos][2] == "S"
	         cItem += "Não foi possível excluir o item." + ENTER
	         Loop
	      EndIf
	      If SC6->(DbSeek(xFilial("SC6")+cPedVen+AvKey(aItens[i][2][2],"C6_ITEM")))
	         For j := 1 To Len(aItens[i])
		         If SC6->(FieldPos(aItens[i][j][1])) > 0 .And. aItens[i][j][2] <> SC6->&(aItens[i][j][1])
		            //RMD - 27/01/15 - Ignora caso seja um dos campos que podem ser atualizados na emissão da NF e estiver em branco no pedido.
		         	If !(aItens[i][j][1] $ cItCpoDiv) .Or. !Empty(aItens[i][j][2])
 	         			cCampo := "Não foi atualizado o campo: 'XXX' com o conteúdo 'YYY'."
			            cCampo := StrTran(cCampo, "XXX", AllTrim(aItens[i][j][1]))
	                    cCampo := StrTran(cCampo, "YYY", Eval(bConv, aItens[i][j][2]))
	                    cItem += cCampo + ENTER
			        EndIf
		         EndIf
		     Next
	      Else
	         cItem += "Não foi possível incluir o item." + ENTER
	      EndIf
	      //LRS - 08/01/2015 - Validação correta para a criação da mensagem de erro de integração, validando a posição do campo LIMPOS
	      If Len(cItem) > 0
	         If (nPosItem := aScan(aItens[i], {|x| x[1] == "C6_ITEM" })) > 0
	  	      		cSeq := AllTrim(aItens[i][nPosItem][2])
	  	      ElseIf (nPosItem := aScan(aItens[i], {|x| x[1] == "LINPOS" })) > 0
	  	      		cSeq := AllTrim(aItens[i][nPosItem][3])
	  	      EndIf
	  	      If !Empty(cSeq)
		         cMensagem += StrTran("Não foi possível integar o item 'XXX' com o Pedido de Venda:", "XXX", cSeq) + ENTER
		         cMensagem += cItem + ENTER + ENTER
		      EndIf
		  EndIf
	   Next
	EndIf  

End Sequence

Return cMensagem

Function EECFat2FreteEmb(cPedFat, cPedExp, aPvlNfs, aPedido, aSavRat, cNFPreemb, dDataMoe, lTpLibPed)
Local aOrd := SaveOrd({"EEC", "EE9", "EE7", "EE8", "SC5", "SC6", "SC9"})
Local i, j, nPos, nPos1
Local lSC9Lock := .F.  // RMD - 24/10/2014
//Busca os Embarques disponíveis
Private aEmbarques := GetEmbarquesNF(cPedFat, cPedExp, aPvlNfs, aSavRat)

Private cPreemb := ""

	//Se encontrou somente um embarque, associa o mesmo para esta nota
	If Len(aEmbarques) == 1
		cPreemb := aEmbarques[1][2]
	EndIf
	
	//Senão, apresenta o Wizard para escolher o embarque
	If Len(aEmbarques) > 1
		WizardFrete(cPedFat, cPedExp, aPvlNfs, aSavRat)
		//O Wizard irá gravar o embarque escolhido na variável cPreemb
	EndIf
	
	//Caso tenha sido definido algum embarque, atualiza o Pedido de Venda com suas informações de Frete/Seguro/Outras Despesas
	If !Empty(cPreemb)
		lTpLibPed := .F.
		//Busca o embarque escolhido em aEmbarques
		If (i := aScan(aEmbarques, {|x| x[2] == cPreemb })) > 0
			//Posiciona na capa do embarque
			EEC->(DbSeek(xFilial()+cPreemb))
			//Trava a capa do Pedido de Venda (já posicionado pelo programa da NF)
			If SC5->(RecLock("SC5", .F.))
			
				//Atualiza os valores de Frete e Seguro
				SC5->C5_FRETE	:= aEmbarques[i][5]    // RMD - 24/10/2014
				SC5->C5_SEGURO	:= aEmbarques[i][6]
				SC5->C5_DESCONT	:= aEmbarques[i][8]
				SC5->C5_DESPESA	:= aEmbarques[i][9]
				
				//Ponto de entrada para possibilitar a atualização de outras informações
				If EasyEntryPoint("EECFAT2")
					ExecBlock("EECFAT2", .F., .F., {"FAT2FRETEEMB_ATU_SC5"})
				EndIf
				
				SC5->(MsUnlock())

				//Atualiza o valor unitário do item subtraindo o valor do Frete Embutido
				If EasyGParam("MV_EEC0039",,.F.) .And. EEC->(FieldPos("EEC_FREEMB")) > 0
					EE8->(DbSetOrder(1))
					EE9->(DbSetOrder(3))
					SC6->(DbSetOrder(1))
					SC9->(DbSetOrder(1))
					// RMD - 24/10/2014
					nFreteNac := 0
					
					aPvlOk := {}
					For j := 1 To Len(aEmbarques[i][4])
						If EE8->(DbSeek(xFilial()+aEmbarques[i][4][j][3]+aEmbarques[i][4][j][4])) .And.;
						   EE9->(DbSeek(xFilial()+cPreemb+aEmbarques[i][4][j][1])) .And.;
						   SC5->(DbSeek(xFilial()+aEmbarques[i][1]))
							If (nPos := aScan(aPvlNfs, {|x| x[1] == aEmbarques[i][1] .And. x[2] == EE8->EE8_FATIT .And. x[3] == aEmbarques[i][4][j][11] })) > 0
								
								/*
									Preço Unitário do item:
									Preço Unitário convertido para a unidade de medida de preço do embarque
									-
									Valor do Frete Embutido unitário rateado para o item convertido para a moeda									
								*/

								If SC9->(DbSeek(xFilial()+aPvlNfs[nPos][1]+aPvlNfs[nPos][2]+aPvlNfs[nPos][3]+aPvlNfs[nPos][6]))
									//Atualiza na liberação (SC9)
									//Valor na moeda do processo
									If !SC9->(IsLocked())
										SC9->(RecLock("SC9", .F.))
										lSC9Lock := .T.
									EndIf
									
									//Busca o Preço FOB Atual
									nPRECOI := AvTransUnid(EE9->EE9_UNPRC, EE9->EE9_UNIDAD, EE9->EE9_COD_I, EE9->EE9_PRECOI, .F., .T.)
									//Busca o Novo Preço em Dolar
									nPrecoNovo := nPRECOI - Round(((EEC->EEC_FREEMB / RecMoeda(dDataBase, SYF->YF_MOEFAT)) / EEC->EEC_VLFOB) * aEmbarques[i][4][j][5] * nPRECOI / aEmbarques[i][4][j][5], AvSx3("EE9_PRECOI", 4))
									//Arredonda e atualiza o preço da liberação
									SC9->C9_PRCVEN := a410Arred(nPrecoNovo,"D2_PRCVEN")
									//Atualiza o valor unitário NF em reais
									aPvlNfs[nPos][5] := a410Arred(xMoeda(SC9->C9_PRCVEN, SC5->C5_MOEDA,1,dDataMoe,8),"D2_PRCVEN")

									nFreteNac += (nPrecoI * aEmbarques[i][4][j][5]) - (SC9->C9_PRCVEN * aEmbarques[i][4][j][5])

									If lSC9Lock
										SC9->(MsUnlock())
									EndIf
									//Atualiza no item do Pedido de Venda (SC6)
									If SC6->(DbSeek(xFilial()+aPvlNfs[nPos][1]+aPvlNfs[nPos][2]+aPvlNfs[nPos][6]))
										SC6->(RecLock("SC6", .F.))
										SC6->C6_PRCVEN := SC9->C9_PRCVEN
										SC6->C6_PRUNIT := SC9->C9_PRCVEN
                                        SC6->C6_VALOR  := A410Arred( SC6->C6_PRCVEN * SC6->C6_QTDVEN, "C6_VALOR" ) //THTS - 28/08/2017 - WCC-528387 / MTRADE-1299
										SC6->(MsUnlock())
									EndIf
								EndIf
							EndIf
						EndIf
					Next
	
					//Apaga as informações de rateio padrão
					If (j := aScan(aSavRat,{|x| x[1] == aEmbarques[i][1] })) > 0
						aSavRat[j][SV_FRETE]  := 0
						aSavRat[j][SV_SEGURO] := 0
						aSavRat[j][SV_DESCONT]:= 0
						aSavRat[j][SV_DESPESA]:= 0
					EndIf
				EndIf				
			
				// RMD - 24/10/2014Soma o valor do frete embutido
				If EasyGParam("MV_EEC0039",,.F.) .And. EEC->(FieldPos("EEC_FREEMB")) > 0
					If nFreteNac > 0
						SC5->C5_FRETE += nFreteNac
					EndIf
				EndIf
			
			EndIf
		EndIf
		
		//Informa o embarque escolhido para o programa do faturamento
		cNFPreemb := cPreemb
		
	EndIf

RestOrd(aOrd, .T.)
Return Nil

/*
Função      : WizardFrete
Parametros  : Nenhum.
Retorno     : Nil
Objetivos   : Apresentar assistente (wizard) para definição do embarque relacionado à nota fiscal.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 03/09/13
*/
Static Function WizardFrete(cPedFat, cPedExp, aPvlNfs, aSavRat)
//Mensagens do wizard
Local cMensagem1, cMensagem2, cMensagem3

Local oWizard
Local oFont    := TFont():New(,, ,,.T.)

Local i

Private aHeaderEmb := {"$EE7_PEDFAT", "EEC_PREEMB", "EE7_PEDIDO", "$Itens", "&EEC_FRPREV", "&EEC_SEGPRE"}//, "$Total", "EEC_DESCON", "EEC_DESPIN"}
Private aHeaderItEmb := {"EE9_SEQEMB", "EE9_COD_I", "EE8_PEDIDO", "$EE8_SEQUEN", "EE9_SLDINI", "&EE9_VLFRET", "&EE9_VLSEGU"}//, "$Total", "EE9_VLDESC", "EE9_VLOUTR"}

Private oBrowseEmb

Private aEmbEdit := aClone(aEmbarques)


	If EasyGParam("MV_EEC0039",,.F.) .And. EEC->(FieldPos("EEC_FREEMB")) > 0
		aAdd(aHeaderEmb, "EEC_FREEMB")
		aAdd(aHeaderitEmb, "EEC_FREEMB")
	EndIf

	//Mensagem de abertura do wizard
	cMensagem1 := StrTran("Esta rotina irá auxilar o processo de associação da nota fiscal do pedido 'XXX' com um processo de embarque de exportação.", "XXX", AllTrim(cPedFat)) + ENTER + ENTER
	cMensagem1 +=  "Serão avaliados os embarques relacionados ao pedido de venda para possibilitar a associação." + ENTER + ENTER
	cMensagem1 +=  "Caso sejam encontrados embarques com saldo disponível, será possível associá-los na tela a seguir." + ENTER + ENTER
	cMensagem1 +=  "Além disso, será possível considerar os valores de frete e o seguro (proporcionais) deste embarque na emissão da nota fiscal."

	DEFINE WIZARD oWizard	TITLE "Assistente de vinculação de embarque";
							HEADER "Início";
							MESSAGE "Easy Export Control";
							TEXT cMensagem1;
							PANEL NEXT	{|| If(Len(aEmbarques) == 0, oWizard:nPanel := 2,), .T. };
							FINISH 		{|| .T.}

		//Painel 1 - Apresentação dos embarques identificados
		//Ao avançar, caso algum embarque tenha sido associado, registra XXXXXXXXXXX
		CREATE PANEL oWizard HEADER "Resultados da Verificação"	MESSAGE "Foram identificados os processo de embarque listados abaixo." + ENTER +;
		                                                      "Clique sobre o embarque para selecionar, além de verificar/ajustar o valor do frete e seguro.";
															  PANEL;
															  FINISH	{|| .F. };
															  EXEC	{|| .T. };
															  NEXT 	{|| If(ValidSel(), (oWizard:nPanel := 3, .T.), .F.) }
	                                                          oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]

			//Browse contendo os embarques disponíveis para vinculação, assim como valores de frete e seguro
			DEFINE FWBROWSE oBrowseEmb DATA ARRAY ARRAY aEmbarques OF oPanel

				//Habilita a edição de células no browse e especifica a função de validação
				oBrowseEmb:SetEditCell(.T.)
				oBrowseEmb:bValidEdit := {|| If( aEmbEdit[oBrowseEmb:At()][5] <> aEmbarques[oBrowseEmb:At()][5] ;
				                                 .Or. aEmbEdit[oBrowseEmb:At()][6] <> aEmbarques[oBrowseEmb:At()][6];
				                                 , RateiaValores(oBrowseEmb:At(), .F.), ) }

				ADD MARKCOLUMN oColumn DATA {|| If(cPreemb == aEmbEdit[oBrowseEmb:At()][2], 'LBOK', 'LBNO') } DOUBLECLICK {|| If(cPreemb == aEmbEdit[oBrowseEmb:At()][2], cPreemb := "", cPreemb := aEmbEdit[oBrowseEmb:At()][2]), oBrowseEmb:Refresh() } OF oBrowseEmb
				For i := 1 To Len(aHeaderEmb)
					//Os itens iniciados com $ no header são utilizados para controles internos e não serão exibidos no browse
					If Left(aHeaderEmb[i], 1) <> "$"
						ADD;
						COLUMN oColumn;
						;//Readvar da célula. Neste caso a manutenção será feita diretamente no array, sem variável de memória
						DATA &('{ || aEmbEdit[oBrowseEmb:At()][' + Str(i) + '] }');
						READVAR 'aEmbEdit[oBrowseEmb:At()][' + Str(i) + ']';
						;//Os itens iniciados com # no Header não fazem parte do dicionário de dados e terão o título igual ao informado no header
						TITLE If(Left(aHeaderEmb[i], 1) == "#", SubStr(aHeaderEmb[i], 2), AvSx3(StrTran(aHeaderEmb[i], "&", ""), AV_TITULO));
						OF oBrowseEmb

						If AvSx3(StrTran(aHeaderEmb[i], "&", ""), AV_TIPO) <> "N"
							oColumn:SetSize(AvSx3(StrTran(aHeaderEmb[i], "&", ""), AV_TAMANHO))
						EndIf
						
						If Left(aHeaderEmb[i], 1) <> "#"
							oColumn:SetPicture(AvSx3(StrTran(aHeaderEmb[i], "&", ""), AV_PICTURE))
						EndIf
						
						//Campo editável
						If Left(aHeaderEmb[i], 1) == "&"
							oColumn:SetEdit(.T.)
						Else
							//Ao dar duplo clique sobre o embarque será exibida tela com detalhamento dos itens e dos valores de frete
							oColumn:SetDoubleClick({|| VerItens(aEmbEdit[oBrowseEmb:At()][3], aEmbEdit[oBrowseEmb:At()][4], oWizard, oBrowseEmb:At()) })
						EndIf
						
					EndIf
				Next

			ACTIVATE FWBROWSE oBrowseEmb

        //Painel 2 - Apresentado somente quando ...
		CREATE PANEL oWizard HEADER "Resultado da Verificação"	PANEL;
											BACK	{|| .F. };
											NEXT	{|| .T. };
										    FINISH	{|| .T. };
											EXEC	{|| .T. }
											oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]

			cMensagem2 := "Não foram identificados processos de embarque para vinculação." + ENTER + ENTER
			cMensagem2 += "A emissão da nota irá prosseguir considerando as informações do Pedido de Venda."
			
			@ 10, 10 Say cMensagem2 Size oPanel:nClientHeight, oPanel:nClientWidth Font oFont Pixel Of oPanel

		//Painel 3 - Finalização da rotina.
		CREATE PANEL oWizard HEADER "Finalização"				MESSAGE "Conferência Final"; 
																PANEL;
																BACK	{|| .F. };
																NEXT	{|| .F. };
																FINISH	{|| .T. };
																EXEC	{|| .T. }
                                                                oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]

			cMensagem3 := "O assistente de vinculação de embarque foi finalizado." + ENTER
			cMensagem3 += ENTER
			cMensagem3 += "Ao concluir a emissão da Nota Fiscal, caso um processo de embarque tenha sido vinculado, o mesmo será atualizado automaticamente." + ENTER
			
			@ 10, 10 Say cMensagem3 Size oPanel:nClientHeight, oPanel:nClientWidth Font oFont Pixel Of oPanel

      ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }
      
      aEmbarques := aClone(aEmbEdit)

Return Nil

/*
Função      : 
Parametros  : 
Retorno     : 
Objetivos   : Buscar os embarques disponíveis para vinculação à NF
Autor       : 
Data/Hora   : 
*/
Static Function GetEmbarquesNF(cPedFat, cPedExp, aPvlNfs, aSavRat)
Local aEmbarques := {}
Local nItem, nFrete, nSeguro, nDesconto, nDespesas, i, nFreEmbut
Local cRateio := EasyGParam("MV_AVG0021",,"3")

	EEC->(DbSetOrder(1))
	EE8->(DbSetOrder(1))

	//Verifica se é fluxo alternativo
	If EEC->(DbSeek(xFilial()+cPedExp)) .And. EEC->(FieldPos("EEC_PEDFAT")) > 0 .And. !Empty(EEC->EEC_PEDFAT)
        EE9->(DbSetOrder(3))
		EE9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
		While EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+EEC->EEC_PREEMB)
		
			cPedExp := EE9->EE9_PEDIDO
		
			EE8->(DbSeek(xFilial()+cPedExp+EE9->EE9_SEQUEN))
			While EE8->(!Eof() .And. EE8_FILIAL+EE8_PEDIDO+EE8_SEQUEN == xFilial()+cPedExp+EE9->EE9_SEQUEN)
				If (nItem := aScan(aPvlNfs, {|aItem| aItem[1] == cPedFat .And. aItem[2] == EE8->EE8_FATIT })) > 0

						If Empty(EE9->EE9_NF) .And. !(PossuiNotaEmitida(cPedFat, EE8->EE8_FATIT, EE9->EE9_PREEMB,,, .T.) >= EE9->EE9_SLDINI)
							If (nEmbarque := aScan(aEmbarques, {|x| x[2] == EE9->EE9_PREEMB })) == 0
								aAdd(aEmbarques, {cPedFat, EE9->EE9_PREEMB, cPedExp, {}, 0, 0, 0, 0, 0})
								nEmbarque := Len(aEmbarques)
							EndIf
							nFrete  := Round((aPvlNfs[nItem][4] / EE9->EE9_SLDINI) * EE9->EE9_VLFRET, AvSx3("EE9_VLFRET", AV_DECIMAL))
							nSeguro := Round((aPvlNfs[nItem][4] / EE9->EE9_SLDINI) * EE9->EE9_VLSEGU, AvSx3("EE9_VLSEGU", AV_DECIMAL))
							nDesconto := Round((aPvlNfs[nItem][4] / EE9->EE9_SLDINI) * EE9->EE9_VLDESC, AvSx3("EE9_VLSEGU", AV_DECIMAL))
							nDespesas := Round((aPvlNfs[nItem][4] / EE9->EE9_SLDINI) * EE9->EE9_VLOUTR, AvSx3("EE9_VLOUTR", AV_DECIMAL))
							aEmbarques[nEmbarque][5] += nFrete
							aEmbarques[nEmbarque][6] += nSeguro
							aEmbarques[nEmbarque][8] += nDesconto
							aEmbarques[nEmbarque][9] += nDespesas
							aAdd(aEmbarques[nEmbarque][4], ({EE9->EE9_SEQEMB, EE9->EE9_COD_I, EE8->EE8_PEDIDO, EE8->EE8_SEQUEN, aPvlNfs[nItem][4], nFrete, nSeguro, 0, nDesconto, nDespesas}))
						EndIf

				EndIf
				EE8->(DbSkip())
            EndDo
            EE9->(DbSkip())
    	EndDo

	Else
		//Fluxo Normal
		EE9->(DbSetOrder(1))
		EE8->(DbSeek(xFilial()+cPedExp))
		//Verifica todos os itens do Pedido de Exportação
		While EE8->(!Eof() .And. EE8_FILIAL+EE8_PEDIDO == xFilial()+cPedExp)
			//Verifica se o item está marcado para esta nota
			aPVLOK := {}
			While (nItem := aScan(aPvlNfs, {|aItem| aItem[1] == cPedFat .And. aItem[2] == EE8->EE8_FATIT .And. aScan(aPVLOK, aItem[3]) == 0 })) > 0
				aAdd(aPvlOK, aPvlNfs[nItem][3])
				
				//Posiciona no item no embarque
				EE9->(DbSeek(xFilial()+EE8->(EE8_PEDIDO+EE8_SEQUEN)))
				aEmbDisp := {}
				While EE9->(!Eof() .And. EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN == xFilial()+EE8->(EE8_PEDIDO+EE8_SEQUEN))
					If aScan(aEmbDisp, EE9->EE9_PREEMB) == 0
						aAdd(aEmbDisp, EE9->EE9_PREEMB)
					EndIf
					EE9->(DbSkip())
				EndDo
				EE9->(DbSeek(xFilial()+EE8->(EE8_PEDIDO+EE8_SEQUEN)))
				While EE9->(!Eof() .And. EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN == xFilial()+EE8->(EE8_PEDIDO+EE8_SEQUEN))
					//Para cada item de embarque referenciado a eadste item do pedido, verifica se já existe NF
					If (Empty(EE9->EE9_NF) .And.;//Verifica se já existe NF comparada
					   !PossuiNotaEmitida(cPedFat, EE8->EE8_FATIT, EE9->EE9_PREEMB,,, .T.) >= EE9->EE9_SLDINI) .Or.;//Verifica se já foi emitida NF mas não comparou
					   (Len(aEmbDisp) == 1 .And. MsgYesNo(StrTran("Deseja basear esta Nota Fiscal nos valores de despesas do embarque 'XXX'?", "XXX", EE9->EE9_PREEMB), "Aviso"))
					   
					   //Adiciona o Embarque no array a Embarques
						If (nEmbarque := aScan(aEmbarques, {|x| x[2] == EE9->EE9_PREEMB })) == 0
							aAdd(aEmbarques, {cPedFat, EE9->EE9_PREEMB, cPedExp, {}, 0, 0, 0, 0, 0})
							nEmbarque := Len(aEmbarques)
						EndIf
						
						//Calcula os valores de Frete/Seguro/Outras Despesas proporcionais a quantidade faturada
						nFrete  := Round((aPvlNfs[nItem][4] / EE9->EE9_SLDINI) * EE9->EE9_VLFRET, AvSx3("EE9_VLFRET", AV_DECIMAL))
						nSeguro := Round((aPvlNfs[nItem][4] / EE9->EE9_SLDINI) * EE9->EE9_VLSEGU, AvSx3("EE9_VLSEGU", AV_DECIMAL))
						nDesconto := Round((aPvlNfs[nItem][4] / EE9->EE9_SLDINI) * EE9->EE9_VLDESC, AvSx3("EE9_VLSEGU", AV_DECIMAL))
						nDespesas := Round((aPvlNfs[nItem][4] / EE9->EE9_SLDINI) * EE9->EE9_VLOUTR, AvSx3("EE9_VLOUTR", AV_DECIMAL))
						
						//Totaliza os valores por embarque
						aEmbarques[nEmbarque][5] += nFrete
						aEmbarques[nEmbarque][6] += nSeguro
						aEmbarques[nEmbarque][8] += nDesconto
						aEmbarques[nEmbarque][9] += nDespesas
						
						//Adiciona o item no array do embarque
						aAdd(aEmbarques[nEmbarque][4], ({EE9->EE9_SEQEMB, EE9->EE9_COD_I, EE8->EE8_PEDIDO, EE8->EE8_SEQUEN, aPvlNfs[nItem][4], nFrete, nSeguro, 0, nDesconto, nDespesas, aPvlNfs[nItem][3]}))
						
					EndIf
					EE9->(DbSkip())
				EndDo
			EndDo
			EE8->(DbSkip())
		EndDo

	EndIf

	//Verifica se possui valor de frete embutido nos itens
	If EasyGParam("MV_EEC0039",,.F.) .And. EEC->(FieldPos("EEC_FREEMB")) > 0 .And. FindFunction("EasyRateio")
		For i := 1 To Len(aEmbarques)
			If EEC->(DbSeek(xFilial()+aEmbarques[i][2])) .And. EEC->EEC_FREEMB > 0
				
				//Busca as quantidades/valores/unidades de medida dos itens do embarque
                  // RMD - 24/10/2014
				BeginSql Alias "QRYEE9"
					Select 
						EE9_UNIDAD, EE9_UNPRC, EE9_COD_I, EE9_PRECOI As PRECO, EE9_SLDINI As QTD
					From 
						%table:EE9% EE9
					Where
						EE9_FILIAL = %XFilial:EE9%
						And EE9_PREEMB = %exp:EEC->EEC_PREEMB%
						AND %NotDel%
				EndSql
				
				If QRYEE9->(Eof() .And. Bof())
					QRYEE9->(DbCloseArea())
					Loop
				EndIf
				
				nTotItens := 0
				nTotPreco := 0
				While QRYEE9->(!Eof())
					
					nTotItens++
					//Total do preço na unidade de medida de quantidade
					nTotPreco += (AvTransUnid(QRYEE9->EE9_UNPRC, QRYEE9->EE9_UNIDAD, QRYEE9->EE9_COD_I, QRYEE9->PRECO, .F., .T.) * QRYEE9->QTD)

					QRYEE9->(DbSkip())
				EndDo
				
				QRYEE9->(DbCloseArea())
				
				SYF->(DBSetOrder(1))
				SYF->(DBSeek(xFilial() + EEC->EEC_MOEDA))
				//O frete embutido é lançado em Reais. Converte o valor para a moeda do processo
				nFreEmbut:= Round(EEC->EEC_FREEMB / RecMoeda(dDataBase, SYF->YF_MOEFAT), AvSx3("EEC_FRPREV", AV_DECIMAL))  // RMD - 24/10/2014

				//Verifica a forma de rateio do frete
				Do Case
					Case cRateio == RAT_PESO_LIQUIDO
						oRateio := EasyRateio():New(nFreEmbut/*EEC->EEC_FREEMB*/, EEC->EEC_PESLIQ, nTotItens, AvSx3("EE9_PRECOI", AV_DECIMAL))
					Case cRateio == RAT_PESO_BRUTO
						oRateio := EasyRateio():New(nFreEmbut/*EEC->EEC_FREEMB*/, EEC->EEC_PESBRU, nTotItens, AvSx3("EE9_PRECOI", AV_DECIMAL))
					Otherwise //cRateio == RAT_PRECO
						oRateio := EasyRateio():New(nFreEmbut/*EEC->EEC_FREEMB*/, nTotPreco, nTotItens, AvSx3("EE9_PRECOI", AV_DECIMAL))
				EndCase
				
				//Busca novamente os itens para ratear os valores
				BeginSql Alias "QRYEE9"
					Select 
						EE9_SEQEMB, EE9_UNPES, EE9_COD_I, EE9_PSLQTO, EE9_UNPES, EE9_PSBRTO, EE9_UNIDAD, EE9_UNPRC, EE9_SLDINI, EE9_PRECOI
					From
						%table:EE9% EE9
					Where
						EE9_FILIAL = %XFilial:EE9%
						And EE9_PREEMB = %exp:EEC->EEC_PREEMB%
						AND %NotDel%
				EndSql
				
				While QRYEE9->(!Eof())
					If cRateio == RAT_PESO_LIQUIDO
						If (nPos := aScan(aEmbarques[i][4], {|x| x[1] == QRYEE9->EE9_SEQEMB })) > 0
							aEmbarques[i][4][nPos][8] := oRateio:GetItemRateio(AvTransUnid(QRYEE9->EE9_UNPES, EEC->EEC_UNIDAD, QRYEE9->EE9_COD_I, QRYEE9->EE9_PSLQTO))
							//Proporcionaliza pela quantidade (mesmo modelo do frete internacional)
							aEmbarques[i][4][nPos][8] := (aEmbarques[i][4][nPos][8] * (aEmbarques[i][4][nPos][5] / QRYEE9->EE9_SLDINI))
						Else
							oRateio:GetItemRateio(AvTransUnid(QRYEE9->EE9_UNPES, EEC->EEC_UNIDAD, QRYEE9->EE9_COD_I, QRYEE9->EE9_PSLQTO))
						EndIf

					ElseIf cRateio == RAT_PESO_BRUTO
						If (nPos := aScan(aEmbarques[i][4], {|x| x[1] == QRYEE9->EE9_SEQEMB })) > 0
							aEmbarques[i][4][nPos][8] := oRateio:GetItemRateio(AvTransUnid(QRYEE9->EE9_UNPES, EEC->EEC_UNIDAD, QRYEE9->EE9_COD_I, QRYEE9->EE9_PSBRTO))
							//Proporcionaliza pela quantidade (mesmo modelo do frete internacional)
							aEmbarques[i][4][nPos][8] := (aEmbarques[i][4][nPos][8] * (aEmbarques[i][4][nPos][5] / QRYEE9->EE9_SLDINI))
						Else
							oRateio:GetItemRateiadmino(AvTransUnid(QRYEE9->EE9_UNPES, EEC->EEC_UNIDAD, QRYEE9->EE9_COD_I, QRYEE9->EE9_PSBRTO))
						EndIf

					Else //cRATEIO == RAT_PRECO
						If (nPos := aScan(aEmbarques[i][4], {|x| x[1] == QRYEE9->EE9_SEQEMB })) > 0
							//Busca o valor do Frete embutido proporcional ao item
							aEmbarques[i][4][nPos][8] := oRateio:GetItemRateio(QRYEE9->EE9_SLDINI * AvTransUnid(QRYEE9->EE9_UNPRC, QRYEE9->EE9_UNIDAD, QRYEE9->EE9_COD_I, QRYEE9->EE9_PRECOI, .F., .T.))
							
							//Proporcionaliza pela quantidade (mesmo modelo do frete internacional)
							aEmbarques[i][4][nPos][8] := (aEmbarques[i][4][nPos][8] * (aEmbarques[i][4][nPos][5] / QRYEE9->EE9_SLDINI))
						Else
							//Abate o valor do controle de rateio
							oRateio:GetItemRateio(QRYEE9->EE9_SLDINI * AvTransUnid(QRYEE9->EE9_UNPRC, QRYEE9->EE9_UNIDAD, QRYEE9->EE9_COD_I, QRYEE9->EE9_PRECOI, .F., .T.))
						EndIf
					EndIf
					
					If nPos > 0
						aEmbarques[i][7] += aEmbarques[i][4][nPos][8]
					EndIf

					QRYEE9->(DbSkip())
				EndDo
				QRYEE9->(DbCloseArea())
            EndIf
    	Next
    EndIf
    
Return aEmbarques


//Verifica se existe NF emitida mas ainda não comparada
Static Function PossuiNotaEmitida(cPedFat, cFatIt, cPreemb, cNf, cSerie, lQuant)
Local xRet := .F.
Default cNF 	:= ""
Default cSerie	:= ""
Default lQuant	:= .F.

	If Empty(cNf)
		BeginSql Alias "QRYSD2"
			Select 
				D2_QUANT
			From
				%table:SD2% SD2
			Where
				D2_FILIAL = %XFilial:SD2%
				And D2_PEDIDO = %exp:cPedFat%
				And D2_ITEMPV = %exp:cFatIt%
				And D2_PREEMB = %exp:cPreemb%
				AND %NotDel%
		EndSql
	Else
		BeginSql Alias "QRYSD2"
			Select 
				D2_QUANT
			From
				%table:SD2% SD2
			Where
				D2_FILIAL 		= %XFilial:SD2%
				And D2_PEDIDO 	= %exp:cPedFat%
				And D2_ITEMPV 	= %exp:cFatIt%
				And D2_PREEMB 	= %exp:cPreemb%
				And D2_DOC		= %exp:cNf%
				And D2_SERIE	= %exp:cSerie%
				AND %NotDel%
		EndSql
	EndIf
	
	If !QRYSD2->(Eof() .And. Bof())
		If !lQuant
			xRet := .T.
		Else
			xRet := 0   // RMD - 24/10/2014
			While QRYSD2->(!Eof())
				xRet += QRYSD2->D2_QUANT
				QRYSD2->(DbSkip())
			EndDo
		EndIf
	Else
		If lQuant
			xRet := 0
		Endif
	EndIf
	
	QRYSD2->(DbCloseArea())

Return xRet


/*
Função      : VerItens
Parametros  : aItens - Array contendo os itens do embarque atual
              oWizard - Objeto do wizard ativo
Retorno     : Nenhum
Objetivos   : Exibir os itens do embarque selecionado e permitir a conferência/ajuste dos valores de frete e seguro
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 03/09/13
*/
Static Function VerItens(cEmbarque, aItensEmbarque, oWizard, nAt)
Local oDlg, i

//Picture para os campos de quantidade de lote
Local cPictureLote := AvSX3("WV_QTDE", AV_PICTURE)

Private aItensEdit := aClone(aItensEmbarque)

Private oBrowseItens
//Private aItensEmbarque := aItens

	DEFINE MSDIALOG oDlg TITLE "Conferência dos itens" FROM 1,1 TO oWizard:oDlg:nClientHeight, oWizard:oDlg:nClientWidth * 1.4 OF oMainWnd PIXEL

		DEFINE FWBROWSE oBrowseItens DATA ARRAY ARRAY aItensEmbarque OF oDlg

			//Habilita a edição de células no browse e especifica a função de validação
			oBrowseItens:SetEditCell(.T.)
			oBrowseItens:bValidEdit := {|| .T. }

			For i := 1 To Len(aHeaderItEmb)
				//Caso o item estiver marcado com $ no header, o mesmo não será exibido no browse
				If Left(aHeaderItEmb[i], 1) <> "$"
					ADD;
					COLUMN oColumn;
					DATA &('{ || aItensEdit[oBrowseItens:At()][' + Str(i) + '] }');
					TITLE If(Left(aHeaderItEmb[i], 1) == "#", SubStr(aHeaderItEmb[i], 2), AvSx3(StrTran(aHeaderItEmb[i], "&", ""), AV_TITULO));
					READVAR 'aItensEdit[oBrowseItens:At()][' + Str(i) + ']';
					OF oBrowseItens
					
					If AvSx3(StrTran(aHeaderItEmb[i], "&", ""), AV_TIPO) <> "N"
						oColumn:SetSize(AvSx3(StrTran(aHeaderItEmb[i], "&", ""), AV_TAMANHO))
					EndIf
					
					If Left(aHeaderItEmb[i], 1) <> "#"
						oColumn:SetPicture(AvSx3(StrTran(aHeaderItEmb[i], "&", ""), AV_PICTURE))
					EndIf
					
					//Se o campo estiver marcado com &, permite a edição do mesmo
					If Left(aHeaderItEmb[i], 1) == "&"
						oColumn:SetEdit(.T.)
					EndIf
					
				EndIf
			Next

		ACTIVATE FWBROWSE oBrowseItens

	ACTIVATE MSDIALOG oDlg CENTERED
	
	aEmbEdit[nAt][4] := aClone(aItensEdit)
	RateiaValores(nAt, .T.)
	
Return Nil

//Rateia os valores digitados de Frete/Seguro/Outras despesas, entre capa e itens
Static Function RateiaValores(n, lItens)
Local i
Local nTotalFrete := 0, nTotalSeguro := 0, nAuxFrete := 0, nAuxSeguro := 0

	If lItens
		//Atualiza o valor de capa com o valor dos itens
		aEmbEdit[n][5] := 0
		aEmbEdit[n][6] := 0
		aEmbEdit[n][7] := 0
		For i := 1 To Len(aEmbEdit[n][4])
			aEmbEdit[n][5] += aEmbEdit[n][4][i][6]
			aEmbEdit[n][6] += aEmbEdit[n][4][i][7]
			If EasyGParam("MV_EEC0039",,.F.) .And. EEC->(FieldPos("EEC_FREEMB")) > 0
				aEmbEdit[n][7] += aEmbEdit[n][4][i][8]
			EndIf
		Next
	Else
		aEval(aEmbEdit[n][4], {|x| nTotalFrete += x[6], nTotalSeguro += x[7] })
		//nTotalFrete -= If(EEC->(FieldPos("EEC_FREEMB")) > 0, aEmbEdit[n][4][i][8], 0) //wfs
		//Atualiza o valor dos itens com o valor da capa
		For i := 1 To Len(aEmbEdit[n][4])
			aEmbEdit[n][4][i][6] += Round((aEmbarques[n][4][i][6] / nTotalFrete ) * (aEmbEdit[n][5] - nTotalFrete ), AvSx3("EE9_VLFRET", AV_DECIMAL))
			aEmbEdit[n][4][i][7] += Round((aEmbarques[n][4][i][7] / nTotalSeguro) * (aEmbEdit[n][6] - nTotalSeguro), AvSx3("EE9_VLSEGU", AV_DECIMAL))
			nAuxFrete += aEmbEdit[n][4][i][6]
			nAuxSeguro += aEmbEdit[n][4][i][7]
			If (i == Len(aEmbEdit[n])) .And. aEmbEdit[n][5] <> nAuxFrete
				aEmbEdit[n][4][i][6] += (aEmbEdit[n][5] - nAuxFrete)
			EndIf
			If (i == Len(aEmbEdit[n])) .And. aEmbEdit[n][6] <> nAuxSeguro
				aEmbEdit[n][4][i][7] += (aEmbEdit[n][6] - nAuxSeguro)
			EndIf
		Next
	EndIf
	
	aEmbarques[n] := aClone(aEmbEdit[n])

Return Nil                                   

//Validação do Wizard
Static Function ValidSel()
Local lRet := .T.

	If Empty(cPreemb)
		MsgInfo("Selecione um embarque para continuar.", "Atenção")
		lRet := .F.
	EndIf

Return lRet


Function EECGetEmbInfo(cPreemb)
Local aRet := {}
Local aOrd := SaveOrd({"EEC", "SYF", "SD2"})
Local nTaxa, nFrete := 0, nQuant

	SD2->(dbSetOrder(3))
	If cPreemb == Nil
   		If SD2->(dbSeek(xFilial()+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))) .And. !Empty(SD2->D2_PREEMB)
   			cPreemb := SD2->D2_PREEMB
   		EndIf
	EndIf
	
	SD2->(dbSetOrder(8))
	EE9->(DbSetOrder(3))
	EE7->(DbSetOrder(1))
	EE8->(DbSetOrder(1))
	If cPreemb <> Nil
		EEC->(DbSetOrder(1))
		SYF->(dbSetOrder(1))
		If EEC->(DbSeek(xFilial()+cPreemb)) .And. SYF->(DbSeek(xFilial()+EEC->EEC_MOEDA))
			nTaxa := RecMoeda(SF2->F2_EMISSAO, SYF->YF_MOEFAT)
			
			EE9->(DbSeek(xFilial()+cPreemb))
			While EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+cPreemb)
				If EE7->(DbSeek(xFilial()+EE9->EE9_PEDIDO)) .And. EE8->(DbSeek(xFilial()+EE9->(EE9_PEDIDO+EE9_SEQUEN)))
					//Fluxo padrão (sem EEC_PEDFAT)
					If EEC->(FieldPos("EEC_PEDFAT")) == 0 .Or. Empty(EEC->EEC_PEDFAT)
						If (nQuant := PossuiNotaEmitida(EE7->EE7_PEDFAT, EE8->EE8_FATIT, EEC->EEC_PREEMB, SF2->F2_DOC, SF2->F2_SERIE, .T.)) > 0
							nFrete += (EE9->EE9_VLFRET / EE9->EE9_SLDINI) * nQuant
						EndIf
					Else
						//Fluxo Alternativo
						If EE9->EE9_NF == SF2->F2_DOC .And. EE9->EE9_SERIE == SF2->F2_SERIE .And. AvKey(SF2->F2_HAWB, "EEC_PREEMB") == EEC->EEC_PREEMB
							SD2->(DbSetOrder(8))
							If SD2->(DbSeek(xFilial()+AvKey(EEC->EEC_PEDFAT, "C5_NUM")+AvKey(EE9->EE9_FATIT, "C6_ITEM")))
								While SD2->(!Eof() .And. D2_FILIAL+D2_PEDIDO+D2_ITEMPV == xFilial()+AvKey(EEC->EEC_PEDFAT, "C5_NUM")+AvKey(EE9->EE9_FATIT, "C6_ITEM"))
									If SD2->(D2_DOC+D2_SERIE) == SF2->(F2_DOC+F2_SERIE)
										nFrete += (EE9->EE9_VLFRET / EE9->EE9_SLDINI) * SD2->D2_QUANT
										Exit
									EndIf
									SD2->(DbSkip())
								EndDo
							Else
								nFrete += EE9->EE9_VLFRET
							EndIf
						EndIf
					EndIf
				EndIf
				EE9->(DbSkip())
			EndDo
			
			//Converte o valor do frete para reais
			nFrete := nFrete * nTaxa

			aRet := {;
					{"PROCESSO"				, EEC->EEC_PREEMB},;
					{"FRETE"				, Round(nFrete, AvSX3("EES_VLFREM", AV_DECIMAL))},;
					{"FRETE_EMBUTIDO"		, If(EasyGParam("MV_EEC0039",,.F.) .And. EEC->(FieldPos("EEC_FREEMB")) > 0 .And. (SF2->F2_FRETE - nFrete) > 0, Round(SF2->F2_FRETE - nFrete, AvSX3("EES_VLFREM", AV_DECIMAL)), 0)},;
					{"INCOTERM"				, EEC->EEC_INCOTE},;
					{"MOEDA"				, EEC->EEC_MOEDA},;
					{"VALOR_TOTAL"			, Round(SF2->F2_VALBRUT / nTaxa, AvSx3("EEC_TOTPED", AV_DECIMAL))},;
					{"TAXA"					, nTaxa};
					}
		EndIf
	EndIf

RestOrd(aOrd, .T.)
Return aRet

Function EECCheckRat(cPreemb)
Local lRet := .T.
Default cPreemb := ""

	If !Empty(cPreemb)
		lRet := .F.
	EndIf

Return lRet

//Recalcula os valores totais dos itens
Function EECFat2AtuRat(aItPedido, aPvlNfs, cPreemb)

	If !Empty(cPreemb)
		aItPedido[5] := 0
		aItPedido[22] := 0
		aEval(aPvlNfs, {|x| If(x[1] == aItPedido[1], (aItPedido[5] += x[4] * x[5], aItPedido[22] += x[4] * x[5]), ) })
	EndIf

Return Nil

//Verifica se a nota foi comparada ao embarque
Function EECFat2ChkNfCmp(cPreemb, cNf, cSerie)
Local lRet := .F.
Default cPreemb := ""

	If !Empty(cPreemb)
		BeginSql Alias "QRYEE9"
			Select 
				Count(*) As TOTAL
			From 
				%table:EE9% EE9
			Where
				EE9_FILIAL = %XFilial:EE9%
				And EE9_PREEMB = %exp:cPreemb%
				And EE9_NF = %exp:cNf%
				And EE9_SERIE = %exp:cSerie%
				AND %NotDel%
		EndSql
		
		QRYEE9->(DbGoTop())
		If !QRYEE9->(Eof() .And. Bof()) .And. QRYEE9->TOTAL > 0
			lRet := .T.
		EndIf
		QRYEE9->(DbCloseArea())
	EndIf

Return lRet

/*
Funcao      : FAT2CposInt()
Parametros  : cAlias
Retorno     : aCpos - Campos integrados
Objetivos   : Carrega array com campos integrados SIGAEEC x SIGAFAT
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 02/09/2013 - 14:20
*/
*------------------------*
Function FAT2CposInt(cAlias)
*------------------------*
Local aCposInt := {}
Local aCpos := {}

Begin Sequence
   If !EasyGParam("MV_EECFAT",,.F.)
      Return NIL
   EndIf
   
   If cAlias == "SC5"
      aAdd(aCposInt,"C5_NUM")
      aAdd(aCposInt,"C5_TIPO")
      aAdd(aCposInt,"C5_CLIENTE")
      aAdd(aCposInt,"C5_LOJACLI")
      aAdd(aCposInt,"C5_TIPOCLI")
      aAdd(aCposInt,"C5_CONDPAG")
      aAdd(aCposInt,"C5_BANCO")
      aAdd(aCposInt,"C5_EMISSAO")
      aAdd(aCposInt,"C5_MOEDA") 
      aAdd(aCposInt,"C5_PESOL") 
      aAdd(aCposInt,"C5_PBRUTO") 
      aAdd(aCposInt,"C5_PEDEXP")
      aAdd(aCposInt,"C5_MOEDTIT") 
      aAdd(aCposInt,"C5_REAJUST")
      aAdd(aCposInt,"C5_DESCONT") 
   ElseIf cAlias == "SC6"
      aAdd(aCposInt,"C6_NUM")
      aAdd(aCposInt,"C6_UNSVEN")
      aAdd(aCposInt,"C6_PRODUTO")
      aAdd(aCposInt,"C6_UM")
      aAdd(aCposInt,"C6_QTDVEN")
      aAdd(aCposInt,"C6_PRCVEN")
      aAdd(aCposInt,"C6_PRUNIT") 
      aAdd(aCposInt,"C6_VALDESC")
      aAdd(aCposInt,"C6_TES")
      aAdd(aCposInt,"C6_CF")
      If EE8->(FieldPos("EE8_OPER")) > 0 
         aAdd(aCposInt,"C6_OPER")   
      EndIf   
      aAdd(aCposInt,"C6_LOCAL")
      aAdd(aCposInt,"C6_ENTREG")
      aAdd(aCposInt,"C6_DESCRI")     
      aAdd(aCposInt,"C6_GRADE")
      aAdd(aCposInt,"C6_ITEMGRD")  
   EndIf
   
   SX3->(DbSetOrder(1))
   SX3->(DbSeek(cAlias))
   Do While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == cAlias
      If X3USO(SX3->X3_USADO) .AND. aScan(aCposInt,{|x| AllTrim(x) == AllTrim(SX3->X3_CAMPO)}) == 0  // GFP - 03/09/2013
         aAdd(aCpos,SX3->X3_CAMPO)
      EndIf
      SX3->(DbSkip())
   EndDo

End Sequence

Return aCpos

/*
Funcao      : EECFat2NFEst()
Parametros  : cPreemb, cNota, cTipo
Retorno     : lRet - (T) quando for possível excluir a NF e (F) caso contrário
              Obs: retorna (T) caso o Nro.Embarque esteja vazio para manter a compatibilidade com o funcionamento anterior.
Objetivos   : Retornar se a Nota pode ser excluída quando o Pedido relacionado estiver na fase de embarque, verificando se
              a nota foi comparada ou não com o embarque informado.
Autor       : Nilson César C. Filho - NCF
Data/Hora   : 24/04/2018 - 18:00
*/
Function EECFat2NFEst(cPreemb, cNota, cTipo)

Local lRet
Default cPreemb   := ""

lRet := Empty(cPreemb)

If !lRet
   EEM->(DbSetOrder(1))
   EEM->(DbGoTop())
   If !EEM->(DbSeek( xFilial("EEM")+AvKey(cPreemb,"EEM_PREEMB")+AvKey(cTipo,"EEM_TIPOCA")+AvKey(cNota,"EEM_NRNF")+AvKey("1","EEM_TIPONF") ))
      lRet := .T.
   EndIf
EndIf

Return lRet
