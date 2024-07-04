#include "GCPA140.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Function GCPA140()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CP8')
oBrowse:SetDescription(STR0001)//'Modalidade X Paragrafo'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Fun��o para cria��o do menu 

@author guilherme.pimentel
@since 06/09/2013
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 		ACTION 'VIEWDEF.GCPA140' 	OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina TITLE STR0003    	ACTION 'VIEWDEF.GCPA140'		OPERATION 3 ACCESS 0	//'Incluir'
ADD OPTION aRotina TITLE STR0011	  	ACTION 'VIEWDEF.GCPA140'		OPERATION 4 ACCESS 0	//'Alterar'
ADD OPTION aRotina TITLE STR0004    	ACTION 'VIEWDEF.GCPA140' 	OPERATION 5 ACCESS 0	//'Excluir'
ADD OPTION aRotina TITLE STR0005   	ACTION 'VIEWDEF.GCPA140'		OPERATION 8 ACCESS 0	//'Imprimir'
ADD OPTION aRotina TITLE STR0006    	ACTION 'VIEWDEF.GCPA140'		OPERATION 9 ACCESS 0	//'Copiar'
ADD OPTION aRotina TITLE STR0012    	ACTION 'A140Carga'			OPERATION 3 ACCESS 0	//'Carregar Leis'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author guilherme.pimentel

@since 23/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel
Local oStrCP8:= FWFormStruct(1,'CP8')
Local oStrCP9:= FWFormStruct(1,'CP9')
Local oStrCPB:= FWFormStruct(1,'CPB')

oModel := MPFormModel():New('GCPA140',,{|oModel|GCP140PVld(oModel)})
oModel:AddFields('CP8MASTER',/*cOwner*/ , oStrCP8)
oModel:AddGrid(  'CP9DETAIL','CP8MASTER', oStrCP9)
oModel:AddGrid(  'CPBDETAIL','CP9DETAIL', oStrCPB)

oModel:SetRelation('CP9DETAIL', { { 'CP9_FILIAL', 'xFilial("CP9")' }, { 'CP9_LEI', 'CP8_LEI' }, { 'CP9_ARTIGO', 'CP8_ARTIGO' } }, CP9->(IndexKey(1)) )
oModel:SetRelation('CPBDETAIL', { { 'CPB_FILIAL', 'xFilial("CPB")' }, { 'CPB_LEI', 'CP8_LEI' }, { 'CPB_ARTIGO', 'CP8_ARTIGO' }, { 'CPB_PARAG', 'CP9_PARAG' } }, CPB->(IndexKey(1)) )

oModel:GetModel("CP9DETAIL"):SetUniqueLine({"CP9_LEI", "CP9_ARTIGO", "CP9_PARAG" })
oModel:GetModel("CPBDETAIL"):SetUniqueLine({"CPB_MODALI"})

oModel:GetModel('CP8MASTER'):SetDescription(STR0007)//'Edital X Artigo'
oModel:GetModel('CP9DETAIL'):SetDescription(STR0008)//'Artigo X Paragrafo'
oModel:GetModel('CPBDETAIL'):SetDescription(STR0009)//'Modalidade'

oModel:SetDescription(STR0010)//'Editais X Paragrafo'

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface

@author guilherme.pimentel

@since 23/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrCP8:= FWFormStruct(2, 'CP8')
Local oStrCP9:= FWFormStruct(2, 'CP9',{|cCampo| !AllTrim(cCampo) $ "CP9_LEI, CP9_ARTIGO"})
Local oStrCPB:= FWFormStruct(2, 'CPB',{|cCampo| !AllTrim(cCampo) $ "CPB_LEI, CPB_ARTIGO, CPB_PARAG"})

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CP8' , oStrCP8, 'CP8MASTER' )
oView:AddGrid( 'VIEW_CP9' , oStrCP9, 'CP9DETAIL' )
oView:AddGrid( 'VIEW_CPB' , oStrCPB, 'CPBDETAIL' )  

oView:CreateHorizontalBox( 'CP8', 20)
oView:CreateHorizontalBox( 'CP9', 50)
oView:CreateHorizontalBox( 'CPB', 30)

oView:SetOwnerView('VIEW_CP8','CP8')
oView:SetOwnerView('VIEW_CP9','CP9')
oView:SetOwnerView('VIEW_CPB','CPB')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A140Carga()
Carga autom�tica das leis

@author Guilherme Pimentel
@since 31/10/2013
@version P11
@return lRet 
/*/
//-------------------------------------------------------------------
Function A140Carga()
Local cTexto:= ""
Local nI	:= 0
Local aItens:= {}
Local nTamParag := TAMSX3("CP9_PARAG")[1]
Local nTamArt   := TAMSX3("CP9_ARTIGO")[1]

If IsBlind() .OR. MSGYESNO(STR0013, STR0014) // "Deseja efetuar a carga das Leis? " ## "Aten��o" 

	Begin Transaction
	
	//-- ART. 24
	CP8->(DbSetOrder(1))
	If	CP8->( ! DbSeek(xFilial("CP8")+"1"+"24") )
		//-- Cabe�alho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="1"
		CP8->CP8_ARTIGO:="24"
		CP8->CP8_DESART:="Dispens�vel de licita��o"
		MsUnLock()
		
		//-- Artigos
		aItens := {;
		{'1','24','I','para obras e servi�os de engenharia de valor at� 10% (dez por cento) do limite previsto na al�nea a, do inciso I do artigo anterior, desde que n�o se refiram a parcelas de uma mesma obra ou servi�o ou ainda para obras e servi�os da mesma natureza e no mesmo local que possam ser realizadas conjunta e concomitantemente; (Reda��o dada pela Lei n� 9.648, de 1998)'},;
		{'1','24','II','para outros servi�os e compras de valor at� 10% (dez por cento) do limite previsto na al�nea a, do inciso II do artigo anterior e para aliena��es, nos casos previstos nesta Lei, desde que n�o se refiram a parcelas de um mesmo servi�o, compra ou aliena��o de maior vulto que possa ser realizada de uma s� vez;  (Reda��o dada pela Lei n� 9.648, de 1998)'},;
		{'1','24','III','nos casos de guerra ou grave perturba��o da ordem;'},;
		{'1','24','IV','nos casos de emerg�ncia ou de calamidade p�blica, quando caracterizada urg�ncia de atendimento de situa��o que possa ocasionar preju�zo ou comprometer a seguran�a de pessoas, obras, servi�os, equipamentos e outros bens, p�blicos ou particulares, e somente para os bens necess�rios ao atendimento da situa��o emergencial ou calamitosa e para as parcelas de obras e servi�os que possam ser conclu�das no prazo m�ximo de 180 (cento e oitenta) dias consecutivos e ininterruptos, contados da ocorr�ncia da emerg�ncia ou calamidade, vedada a prorroga��o dos respectivos contratos;'},;
		{'1','24','V','quando n�o acudirem interessados � licita��o anterior e esta, justificadamente, n�o puder ser repetida sem preju�zo para a Administra��o, mantidas, neste caso, todas as condi��es preestabelecidas;'},;
		{'1','24','VI','quando a Uni�o tiver que intervir no dom�nio econ�mico para regular pre�os ou normalizar o abastecimento;'},;
		{'1','24','VII','quando as propostas apresentadas consignarem pre�os manifestamente superiores aos praticados no mercado nacional, ou forem incompat�veis com os fixados pelos �rg�os oficiais competentes, casos em que, observado o par�grafo �nico do art. 48 desta Lei e, persistindo a situa��o, ser� admitida a adjudica��o direta dos bens ou servi�os, por valor n�o superior ao constante do registro de pre�os, ou dos servi�os;     (Vide � 3� do art. 48)'},;
		{'1','24','VIII','para a aquisi��o, por pessoa jur�dica de direito p�blico interno, de bens produzidos ou servi�os prestados por �rg�o ou entidade que integre a Administra��o P�blica e que tenha sido criado para esse fim espec�fico em data anterior � vig�ncia desta Lei, desde que o pre�o contratado seja compat�vel com o praticado no mercado; (Reda��o dada pela Lei n� 8.883, de 1994)'},;
		{'1','24','IX','quando houver possibilidade de comprometimento da seguran�a nacional, nos casos estabelecidos em decreto do Presidente da Rep�blica, ouvido o Conselho de Defesa Nacional; (Regulamento)'},;
		{'1','24','X','para a compra ou loca��o de im�vel destinado ao atendimento das finalidades prec�puas da administra��o, cujas necessidades de instala��o e localiza��o condicionem a sua escolha, desde que o pre�o seja compat�vel com o valor de mercado, segundo avalia��o pr�via;(Reda��o dada pela Lei n� 8.883, de 1994)'},;
		{'1','24','XI','na contrata��o de remanescente de obra, servi�o ou fornecimento, em conseq��ncia de rescis�o contratual, desde que atendida a ordem de classifica��o da licita��o anterior e aceitas as mesmas condi��es oferecidas pelo licitante vencedor, inclusive quanto ao pre�o, devidamente corrigido;'},;
		{'1','24','XII','nas compras de hortifrutigranjeiros, p�o e outros g�neros perec�veis, no tempo necess�rio para a realiza��o dos processos licitat�rios correspondentes, realizadas diretamente com base no pre�o do dia; (Reda��o dada pela Lei n� 8.883, de 1994)'},;
		{'1','24','XIII','na contrata��o de institui��o brasileira incumbida regimental ou estatutariamente da pesquisa, do ensino ou do desenvolvimento institucional, ou de institui��o dedicada � recupera��o social do preso, desde que a contratada detenha inquestion�vel reputa��o �tico-profissional e n�o tenha fins lucrativos;(Reda��o dada pela Lei n� 8.883, de 1994)'},;
		{'1','24','XIV','para a aquisi��o de bens ou servi�os nos termos de acordo internacional espec�fico aprovado pelo Congresso Nacional, quando as condi��es ofertadas forem manifestamente vantajosas para o Poder P�blico;   (Reda��o dada pela Lei n� 8.883, de 1994)'},;
		{'1','24','XV','para a aquisi��o ou restaura��o de obras de arte e objetos hist�ricos, de autenticidade certificada, desde que compat�veis ou inerentes �s finalidades do �rg�o ou entidade.'},;
		{'1','24','XVI','para a impress�o dos di�rios oficiais, de formul�rios padronizados de uso da administra��o, e de edi��es t�cnicas oficiais, bem como para presta��o de servi�os de inform�tica a pessoa jur�dica de direito p�blico interno, por �rg�os ou entidades que integrem a Administra��o P�blica, criados para esse fim espec�fico;(Inclu�do pela Lei n� 8.883, de 1994)'},;
		{'1','24','XVII','para a aquisi��o de componentes ou pe�as de origem nacional ou estrangeira, necess�rios � manuten��o de equipamentos durante o per�odo de garantia t�cnica, junto ao fornecedor original desses equipamentos, quando tal condi��o de exclusividade for indispens�vel para a vig�ncia da garantia; (Inclu�do pela Lei n� 8.883, de 1994)'},;
		{'1','24','XVIII','nas compras ou contrata��es de servi�os para o abastecimento de navios, embarca��es, unidades a�reas ou tropas e seus meios de deslocamento quando em estada eventual de curta dura��o em portos, aeroportos ou localidades diferentes de suas sedes, por motivo de movimenta��o operacional ou de adestramento, quando a exiguidade dos prazos legais puder comprometer a normalidade e os prop�sitos das opera��es e desde que seu valor n�o exceda ao limite previsto na al�nea a do inciso II do art. 23 desta Lei: (Inclu�do pela Lei n� 8.883, de 1994)'},;
		{'1','24','XIX','para as compras de material de uso pelas For�as Armadas, com exce��o de materiais de uso pessoal e administrativo, quando houver necessidade de manter a padroniza��o requerida pela estrutura de apoio log�stico dos meios navais, a�reos e terrestres, mediante parecer de comiss�o institu�da por decreto; (Inclu�do pela Lei n� 8.883, de 1994)'},;
		{'1','24','XX','na contrata��o de associa��o de portadores de defici�ncia f�sica, sem fins lucrativos e de comprovada idoneidade, por �rg�os ou entidades da Admininistra��o P�blica, para a presta��o de servi�os ou fornecimento de m�o-de-obra, desde que o pre�o contratado seja compat�vel com o praticado no mercado. (Inclu�do pela Lei n� 8.883, de 1994)'},;
		{'1','24','XXI','para a aquisi��o de bens e insumos destinados exclusivamente � pesquisa cient�fica e tecnol�gica com recursos concedidos pela Capes, pela Finep, pelo CNPq ou por outras institui��es de fomento a pesquisa credenciadas pelo CNPq para esse fim espec�fico; (Reda��o dada pela Lei n� 12.349, de 2010)'},;
		{'1','24','XXII','na contrata��o de fornecimento ou suprimento de energia el�trica e g�s natural com concession�rio, permission�rio ou autorizado, segundo as normas da legisla��o espec�fica; (Inclu�do pela Lei n� 9.648, de 1998)'},;
		{'1','24','XXIII','na contrata��o realizada por empresa p�blica ou sociedade de economia mista com suas subsidi�rias e controladas, para a aquisi��o ou aliena��o de bens, presta��o ou obten��o de servi�os, desde que o pre�o contratado seja compat�vel com o praticado no mercado. (Inclu�do pela Lei n� 9.648, de 1998)'},;
		{'1','24','XXIV','para a celebra��o de contratos de presta��o de servi�os com as organiza��es sociais, qualificadas no �mbito das respectivas esferas de governo, para atividades contempladas no contrato de gest�o. (Inclu�do pela Lei n� 9.648, de 1998)'},;
		{'1','24','XXV','na contrata��o realizada por Institui��o Cient�fica e Tecnol�gica - ICT ou por ag�ncia de fomento para a transfer�ncia de tecnologia e para o licenciamento de direito de uso ou de explora��o de cria��o protegida. (Inclu�do pela Lei n� 10.973, de 2004)'},;
		{'1','24','XXVI','na celebra��o de contrato de programa com ente da Federa��o ou com entidade de sua administra��o indireta, para a presta��o de servi�os p�blicos de forma associada nos termos do autorizado em contrato de cons�rcio p�blico ou em conv�nio de coopera��o. (Inclu�do pela Lei n� 11.107, de 2005)'},;
		{'1','24','XXVII','na contrata��o da coleta, processamento e comercializa��o de res�duos s�lidos urbanos recicl�veis ou reutiliz�veis, em �reas com sistema de coleta seletiva de lixo, efetuados por associa��es ou cooperativas formadas exclusivamente por pessoas f�sicas de baixa renda reconhecidas pelo poder p�blico como catadores de materiais recicl�veis, com o uso de equipamentos compat�veis com as normas t�cnicas, ambientais e de sa�de p�blica. (Reda��o dada pela Lei n� 11.445, de 2007).'},;
		{'1','24','XXVIII','para o fornecimento de bens e servi�os, produzidos ou prestados no Pa�s, que envolvam, cumulativamente, alta complexidade tecnol�gica e defesa nacional, mediante parecer de comiss�o especialmente designada pela autoridade m�xima do �rg�o. (Inclu�do pela Lei n� 11.484, de 2007).'},;
		{'1','24','XXIX','na aquisi��o de bens e contrata��o de servi�os para atender aos contingentes militares das For�as Singulares brasileiras empregadas em opera��es de paz no exterior, necessariamente justificadas quanto ao pre�o e � escolha do fornecedor ou executante e ratificadas pelo Comandante da For�a. (Inclu�do pela Lei n� 11.783, de 2008).'},;
		{'1','24','XXX','na contrata��o de institui��o ou organiza��o, p�blica ou privada, com ou sem fins lucrativos, para a presta��o de servi�os de assist�ncia t�cnica e extens�o rural no �mbito do Programa Nacional de Assist�ncia T�cnica e Extens�o Rural na Agricultura Familiar e na Reforma Agr�ria, institu�do por lei federal.   (Inclu�do pela Lei n� 12.188, de 2.010)  Vig�ncia'},;
		{'1','24','XXXI','nas contrata��es visando ao cumprimento do disposto nos arts. 3o, 4o, 5o e 20 da Lei no 10.973, de 2 de dezembro de 2004, observados os princ�pios gerais de contrata��o dela constantes. (Inclu�do pela Lei n� 12.349, de 2010)'},;
		{'1','24','XXXII','na contrata��o em que houver transfer�ncia de tecnologia de produtos estrat�gicos para o Sistema �nico de Sa�de - SUS, no �mbito da Lei no 8.080, de 19 de setembro de 1990, conforme elencados em ato da dire��o nacional do SUS, inclusive por ocasi�o da aquisi��o destes produtos durante as etapas de absor��o tecnol�gica. (Inclu�do pela Lei n� 12.715, de 2012)'},;
		{'1','24','XXXIII','na contrata��o de entidades privadas sem fins lucrativos, para a implementa��o de cisternas ou outras tecnologias sociais de acesso � �gua para consumo humano e produ��o de alimentos, para beneficiar as fam�lias rurais de baixa renda atingidas pela seca ou falta regular de �gua.  (Inclu�do pela Medida Provis�ria n� 619, de 2013)       (Vide Decreto n� 8.038, de 2013)'},;
		{'1','24','1�','Os percentuais referidos nos incisos I e II do caput deste artigo ser�o 20% (vinte por cento) para compras, obras e servi�os contratados por cons�rcios p�blicos, sociedade de economia mista, empresa p�blica e por autarquia ou funda��o qualificadas, na forma da lei, como Ag�ncias Executivas. (Inclu�do pela Lei n� 12.715, de 2012)'},;
		{'1','24','2�','O limite temporal de cria��o do �rg�o ou entidade que integre a administra��o p�blica estabelecido no inciso VIII do caput deste artigo n�o se aplica aos �rg�os ou entidades que produzem produtos estrat�gicos para o SUS, no �mbito da Lei no 8.080, de 19 de setembro de 1990, conforme elencados em ato da dire��o nacional do SUS. (Inclu�do pela Lei n� 12.715, de 2012)'};
		}
		For nI := 1 to Len(aItens)
			RecLock("CP9",.T.)
			
			CP9->CP9_FILIAL:=xFilial("CP9")
			CP9->CP9_LEI:=aItens[nI,1]
			CP9->CP9_ARTIGO:=aItens[nI,2]
			CP9->CP9_PARAG:=aItens[nI,3] 
			CP9->CP9_DESPAR:=aItens[nI,4] 
			MsUnLock()
		Next

		//-- Modalidades
		aItens := {;
		{'1','24','I','DL'},;
		{'1','24','II','DL'},;
		{'1','24','III','DL'},;
		{'1','24','IV','DL'},;
		{'1','24','V','DL'},;
		{'1','24','VI','DL'},;
		{'1','24','VII','DL'},;
		{'1','24','VIII','DL'},;
		{'1','24','IX','DL'},;
		{'1','24','X','DL'},;
		{'1','24','XI','DL'},;
		{'1','24','XII','DL'},;
		{'1','24','XIII','DL'},;
		{'1','24','XIV','DL'},;
		{'1','24','XV','DL'},;
		{'1','24','XVI','DL'},;
		{'1','24','XVII','DL'},;
		{'1','24','XVIII','DL'},;
		{'1','24','XIX','DL'},;
		{'1','24','XX','DL'},;
		{'1','24','XXI','DL'},;
		{'1','24','XXII','DL'},;
		{'1','24','XXIII','DL'},;
		{'1','24','XXIV','DL'},;
		{'1','24','XXV','DL'},;
		{'1','24','XXVI','DL'},;
		{'1','24','XXVII','DL'},;
		{'1','24','XXVIII','DL'},;
		{'1','24','XXIX','DL'},;
		{'1','24','XXX','DL'},;
		{'1','24','XXXI','DL'},;
		{'1','24','XXXII','DL'},;
		{'1','24','XXXIII','DL'},;
		{'1','24','1�','DL'},;
		{'1','24','2�','DL'};
		}
		
		For nI := 1 to Len(aItens)
			RecLock("CPB",.T.)
			CPB->CPB_FILIAL:=xFilial("CPB")
			CPB->CPB_LEI:=aItens[nI,1]
			CPB->CPB_ARTIGO:=aItens[nI,2]
			CPB->CPB_PARAG:=aItens[nI,3]
			CPB->CPB_MODALI:=aItens[nI,4]
			MsUnLock()
		Next
	EndIf
	
	//-- ART. 25
	If	CP8->( ! DbSeek(xFilial("CP8")+"1"+"25") )
		//-- Cabe�alho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="1"
		CP8->CP8_ARTIGO:="25"
		CP8->CP8_DESART:="Inexig�vel de licita��o"
		MsUnLock()	

		//-- Artigos
		aItens := {;
		{'1','25','I','para aquisi��o de materiais, equipamentos, ou g�neros que s� possam ser fornecidos por produtor, empresa ou representante comercial exclusivo, vedada a prefer�ncia de marca, devendo a comprova��o de exclusividade ser feita atrav�s de atestado fornecido pelo �rg�o de registro do com�rcio do local em que se realizaria a licita��o ou a obra ou o servi�o, pelo Sindicato, Federa��o ou Confedera��o Patronal, ou, ainda, pelas entidades equivalentes'},;
		{'1','25','II','para a contrata��o de servi�os t�cnicos enumerados no art. 13 desta Lei, de natureza singular, com profissionais ou empresas de not�ria especializa��o, vedada a inexigibilidade para servi�os de publicidade e divulga��o'},;
		{'1','25','III','para contrata��o de profissional de qualquer setor art�stico, diretamente ou atrav�s de empres�rio exclusivo, desde que consagrado pela cr�tica especializada ou pela opini�o p�blica.'},;
		{'1','25','1�','Considera-se de not�ria especializa��o o profissional ou empresa cujo conceito no campo de sua especialidade, decorrente de desempenho anterior, estudos, experi�ncias, publica��es, organiza��o, aparelhamento, equipe t�cnica, ou de outros requisitos relacionados com suas atividades, permita inferir que o seu trabalho � essencial e indiscutivelmente o mais adequado � plena satisfa��o do objeto do contrato.'},;
		{'1','25','2�','Na hip�tese deste artigo e em qualquer dos casos de dispensa, se comprovado superfaturamento, respondem solidariamente pelo dano causado � Fazenda P�blica o fornecedor ou o prestador de servi�os e o agente p�blico respons�vel, sem preju�zo de outras san��es legais cab�veis.'};
		}
		
		For nI := 1 to Len(aItens)
			RecLock("CP9",.T.)
			CP9->CP9_FILIAL:=xFilial("CP9")
			CP9->CP9_LEI:=aItens[nI,1]
			CP9->CP9_ARTIGO:=aItens[nI,2]
			CP9->CP9_PARAG:=aItens[nI,3] 
			CP9->CP9_DESPAR:=aItens[nI,4] 
			MsUnLock()
		Next

		//-- Modalidades
		aItens := {;
		{'1','25','I','IN'},;
		{'1','25','II','IN'},;
		{'1','25','III','IN'},;
		{'1','25','1�','IN'},;
		{'1','25','2�','IN'};
		}
		
		For nI := 1 to Len(aItens)
			RecLock("CPB",.T.)
			CPB->CPB_FILIAL:=xFilial("CPB")
			CPB->CPB_LEI:=aItens[nI,1]
			CPB->CPB_ARTIGO:=aItens[nI,2]
			CPB->CPB_PARAG:=aItens[nI,3]
			CPB->CPB_MODALI:=aItens[nI,4]
			MsUnLock()
		Next
		
	EndIf
	
	//-- ART. 26
	If	CP8->( ! DbSeek(xFilial("CP8")+"1"+"26") )
		//-- Cabe�alho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="1"
		CP8->CP8_ARTIGO:="26"
		CP8->CP8_DESART:="Dispensas Previstas"
		MsUnLock()	

		//-- Artigos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="26"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="caracteriza��o da situa��o emergencial ou calamitosa que justifique a dispensa, quando for o caso;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="26"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="raz�o da escolha do fornecedor ou executante;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="26"
		CP9->CP9_PARAG:="III" 
		CP9->CP9_DESPAR:="justificativa do pre�o." 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="26"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="documento de aprova��o dos projetos de pesquisa aos quais os bens ser�o alocados.  (Inclu�do pela Lei n� 9.648, de 1998)" 
		MsUnLock()
		
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="IN"
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="III"
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="IN"
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="DL"
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="III"
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="DL"
		MsUnLock()
				
		
	EndIf
	
	//-- ART. 01 - RDC	
	If	CP8->( ! DbSeek(xFilial("CP8")+"4"+"01") )
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="4"
		CP8->CP8_ARTIGO:="01"
		CP8->CP8_DESART:="Aplica��o RDC"
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="dos Jogos Ol�mpicos e Paraol�mpicos de 2016, constantes da Carteira de Projetos Ol�mpicos a ser definida pela Autoridade P�blica Ol�mpica (APO); " 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="da Copa das Confedera��es da Federa��o Internacional de Futebol Associa��o - Fifa 2013 e da Copa do Mundo Fifa 2014, definidos pelo Grupo Executivo - Gecopa 2014 do Comit� Gestor institu�do para definir, aprovar e supervisionar as a��es previstas no Plano Estrat�gico das A��es do Governo Brasileiro para a realiza��o da Copa do Mundo Fifa 2014 - CGCOPA 2014, restringindo-se, no caso de obras p�blicas, �s constantes da matriz de responsabilidades celebrada entre a Uni�o, Estados, Distrito Federal e Munic�pios;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="III" 
		CP9->CP9_DESPAR:="de obras de infraestrutura e de contrata��o de servi�os para os aeroportos das capitais dos Estados da Federa��o distantes at� 350 km (trezentos e cinquenta quil�metros) das cidades sedes dos mundiais referidos nos incisos I e II. " 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="das a��es integrantes do Programa de Acelera��o do Crescimento (PAC)" 
		MsUnLock()		
				
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="V" 
		CP9->CP9_DESPAR:="das obras e servi�os de engenharia no �mbito do Sistema �nico de Sa�de � SUS" 
		MsUnLock()		
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="VI" 
		CP9->CP9_DESPAR:="das obras e servi�os de engenharia para constru��o, amplia��o e reforma de estabelecimentos penais e unidades de atendimento socioeducativo. Para obras na �rea da Educa��o " 
		MsUnLock()		
		
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="III" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="V" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="VI" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()
		
	EndIf
	
	//-- ART. 14 - RDC	
	If	CP8->( ! DbSeek(xFilial("CP8")+"4"+"14") )
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="4"
		CP8->CP8_ARTIGO:="14"
		CP8->CP8_DESART:="Amplia��o da oferta da educa��o infantil"
		MsUnLock()	
			
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="14"
		CP9->CP9_PARAG:="3�" 
		CP9->CP9_DESPAR:="o RDC tamb�m � aplic�vel �s licita��es e contratos necess�rios � realiza��o de obras e servi�os de engenharia no �mbito dos sistemas p�blicos de ensino. (NR)" 
		MsUnLock()	
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="14"
		CPB->CPB_PARAG:="3�" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()
		
	EndIf
	
	// ART 57
	//-- ART. 14 - RDC	
	If	CP8->( ! DbSeek(xFilial("CP8")+"1"+"57") )
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="1"
		CP8->CP8_ARTIGO:="57"
		CP8->CP8_DESART:="Dura��o dos contratos regidos por esta Lei ficar� adstrita � vig�ncia dos respectivos cr�ditos or�ament�rios"
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="57"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="aos projetos cujos produtos estejam contemplados nas metas estabelecidas no Plano Plurianual, os quais poder�o ser prorrogados se houver interesse da Administra��o e desde que isso tenha sido previsto no ato convocat�rio;" 
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="57"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="� presta��o de servi�os a serem executados de forma cont�nua, que poder�o ter a sua dura��o prorrogada por iguais e sucessivos per�odos com vistas � obten��o de pre�os e condi��es mais vantajosas para a administra��o, limitada a sessenta meses;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="57"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="ao aluguel de equipamentos e � utiliza��o de programas de inform�tica, podendo a dura��o estender-se pelo prazo de at� 48 (quarenta e oito) meses ap�s o in�cio da vig�ncia do contrato." 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="57"
		CP9->CP9_PARAG:="V" 
		CP9->CP9_DESPAR:="�s hip�teses previstas nos incisos IX, XIX, XXVIII e XXXI do art. 24, cujos contratos poder�o ter vig�ncia por at� 120 (cento e vinte) meses, caso haja interesse da administra��o." 
		MsUnLock()
		
	EndIf
	
	//-- ART. 48
	a017Artigos()
	
	//-- ART. 65 - Da Altera��o dos Contratos - Lei 8.666	
	If	CP8->( ! DbSeek(xFilial("CP8")+"1"+"65") )
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="1"
		CP8->CP8_ARTIGO:="65"
		CP8->CP8_DESART:="Os contratos regidos por esta Lei poder�o ser alterados, com as devidas justificativas, nos seguintes casos:"
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="65"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="unilateralmente pela Administra��o:" 
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="65"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="por acordo das partes:" 
		MsUnLock()
		
	EndIf	
	
	//-- ART. 65 - Da Altera��o dos Contratos - Lei 8.666	
	If	CP8->( ! DbSeek(xFilial("CP8")+"3"+"65") )
		
		//-- Artigo
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="3"
		CP8->CP8_ARTIGO:="65"
		CP8->CP8_DESART:=STR0015 	//-- Altera��o dos contratos. (Lei 8.666)                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
		MsUnLock()	
		
		//-- Paragrafos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="3"
		CP9->CP9_ARTIGO:="65"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:=STR0016	//-- Unilateralmente pela administra��o.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="3"
		CP9->CP9_ARTIGO:="65"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:=STR0017	//-- Por acordo das partes.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            	
		MsUnLock()
		
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="3"
		CPB->CPB_ARTIGO:="65"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="PG" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="3"
		CPB->CPB_ARTIGO:="65"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="PG" 
		MsUnLock()
		
	EndIf	
	
	//-- ART. 09 - RLC || Regulamentos de Licita��es e Contratos do SENAI (fonte)
	CP8->(DbSetOrder(1))
	If	CP8->( ! DbSeek(xFilial("CP8")+"2"+"09") )
		//-- Cabe�alho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="2"
		CP8->CP8_ARTIGO:="09"
		CP8->CP8_DESART:="Dispens�vel de licita��o"
		MsUnLock()
		
		//-- Artigos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="nas contrata��es at� os valores previstos nos incisos I, al�nea �a� e II, al�nea �a� do art. 6�;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="nas aliena��es de bens at� o valor previsto no inciso III, al�nea �a� do art. 6�;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="III" 
		CP9->CP9_DESPAR:="quando n�o acudirem interessados � licita��o e esta n�o puder ser repetida sem preju�zo, mantidas, neste caso, as condi��es preestabelecidas;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="nos casos de calamidade p�blica ou grave perturba��o da ordem p�blica;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="V" 
		CP9->CP9_DESPAR:="nos casos de emerg�ncia, quando caracterizada a necessidade de atendimento a situa��o que possa ocasionar preju�zo ou comprometer a seguran�a de pessoas, obras, servi�os, equipamentos e outros bens;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="VI" 
		CP9->CP9_DESPAR:="na aquisi��o, loca��o ou arrendamento de im�veis, sempre precedida de avalia��o;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="VII" 
		CP9->CP9_DESPAR:="na aquisi��o de g�neros aliment�cios perec�veis, com base no pre�o do dia;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="VIII" 
		CP9->CP9_DESPAR:="na contrata��o de entidade incumbida regimental ou estatutariamente da pesquisa, do ensino ou do desenvolvimento institucional, cient�fico ou tecnol�gico, desde que sem fins lucrativos;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="IX" 
		CP9->CP9_DESPAR:="na contrata��o, com servi�os sociais aut�nomos e com �rg�os e entidades integrantes da Administra��o P�blica, quando o objeto do contrato for compat�vel com as atividades final�sticas do contratado;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="X" 
		CP9->CP9_DESPAR:="na aquisi��o de componentes ou pe�as necess�rios � manuten��o de equipamentos durante o per�odo de garantia t�cnica, junto a fornecedor original desses equipamentos, quando tal condi��o for indispens�vel para a vig�ncia da garantia;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XI" 
		CP9->CP9_DESPAR:="nos casos de urg�ncia para o atendimento de situa��es comprovadamente imprevistas ou imprevis�veis em tempo h�bil para se realizar a licita��o;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XII" 
		CP9->CP9_DESPAR:="na contrata��o de pessoas f�sicas ou jur�dicas para ministrar cursos ou prestar servi�os de instrutoria vinculados �s atividades final�sticas;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XIII" 
		CP9->CP9_DESPAR:="na contrata��o de servi�os de manuten��o em que seja pr�-condi��o indispens�vel para a realiza��o da proposta a desmontagem do equipamento;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XIV" 
		CP9->CP9_DESPAR:="na contrata��o de cursos abertos, destinados a treinamento e aperfei�oamento dos empregados;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XV" 
		CP9->CP9_DESPAR:="na venda de a��es, que poder�o ser negociadas em bolsas;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XVI" 
		CP9->CP9_DESPAR:="para a aquisi��o ou restaura��o de obras de arte e objetos hist�ricos, de autenticidade certificada, desde que compat�veis ou inerentes �s finalidades da Entidade;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XVII" 
		CP9->CP9_DESPAR:="na contrata��o de remanescente de obra, servi�o ou fornecimento em conseq��ncia de rescis�o contratual, desde que atendida a ordem de classifica��o da licita��o anterior e aceitas as mesmas condi��es oferecidas pelo licitante vencedor, inclusive quanto ao pre�o, devidamente corrigido." 
		MsUnLock()		
		
									
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="III" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="V" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="VI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="VII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="VIII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="IX" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="X" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XIII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XIV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XVI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XVII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()	
				
	EndIf
	
	//-- ART. 10 - RLC || Regulamentos de Licita��es e Contratos do SENAI (fonte)
	CP8->(DbSetOrder(1))
	If	CP8->( ! DbSeek(xFilial("CP8")+"2"+"10") )
		//-- Cabe�alho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="2"
		CP8->CP8_ARTIGO:="10"
		CP8->CP8_DESART:="Inexig�vel de licita��o"
		MsUnLock()
		
		//-- Artigos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="10"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="na aquisi��o de materiais, equipamentos ou g�neros diretamente de produtor ou fornecedor exclusivo;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="10"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="na contrata��o de servi�os com empresa ou profissional de not�ria especializa��o, assim entendido aqueles cujo conceito no campo de sua especialidade, decorrente de desempenho anterior, estudos, experi�ncias, publica��es, organiza��o, aparelhamento, equipe t�cnica ou outros requisitos relacionados com sua atividade, permita inferir que o seu trabalho � o mais adequado � plena satisfa��o do objeto a ser contratado;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="10"
		CP9->CP9_PARAG:="III" 
		CP9->CP9_DESPAR:="na contrata��o de profissional de qualquer setor art�stico;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="10"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="na permuta ou da��o em pagamento de bens, observada a avalia��o atualizada;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="10"
		CP9->CP9_PARAG:="V" 
		CP9->CP9_DESPAR:="na doa��o de bens." 
		MsUnLock()
		
		//-- Modalidades // -- Inexigibilidade
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="10"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="10"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="10"
		CPB->CPB_PARAG:="III" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="10"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="10"
		CPB->CPB_PARAG:="V" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
	EndIf
	//Artigos, incisos e par�grados da lei 13.303 para o Artigo 29 (DISPENSA DE LICITACAO)
	If	CP8->(!DbSeek(xFilial("CP8")+"5"+"29"))		
		//-- Cabe�alho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="5"
		CP8->CP8_ARTIGO:="29"
		CP8->CP8_DESART:="Dispens�vel de Licita��o"
		MsUnLock()
		
		//-- Artigos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="para obras e servi�os de engenharia de valor at� R$ 100.000,00 (cem mil reais), desde que n�o se refiram a parcelas de uma mesma obra ou servi�o ou ainda a obras e servi�os de mesma natureza e no mesmo local que possam ser realizadas conjunta e concomitantemente" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="para outros servi�os e compras de valor at� R$ 50.000,00 (cinquenta mil reais) e para aliena��es, nos casos previstos nesta Lei, desde que n�o se refiram a parcelas de um mesmo servi�o, compra ou aliena��o de maior vulto que possa ser realizado de uma s� vez" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="III" 
		CP9->CP9_DESPAR:="quando n�o acudirem interessados � licita��o anterior e essa, justificadamente, n�o puder ser repetida sem preju�zo para a empresa p�blica ou a sociedade de economia mista, bem como para suas respectivas subsidi�rias, desde que mantidas as condi��es preestabelecidas" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="quando as propostas apresentadas consignarem pre�os manifestamente superiores aos praticados no mercado nacional ou incompat�veis com os fixados pelos �rg�os oficiais competentes" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="V" 
		CP9->CP9_DESPAR:="para a compra ou loca��o de im�vel destinado ao atendimento de suas finalidades prec�puas, quando as necessidades de instala��o e localiza��o condicionarem a escolha do im�vel, desde que o pre�o seja compat�vel com o valor de mercado, segundo avalia��o pr�via" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="VI" 
		CP9->CP9_DESPAR:="na contrata��o de remanescente de obra, de servi�o ou de fornecimento, em consequ�ncia de rescis�o contratual, desde que atendida a ordem de classifica��o da licita��o anterior e aceitas as mesmas condi��es do contrato encerrado por rescis�o ou distrato, inclusive quanto ao pre�o, devidamente corrigido" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="VII" 
		CP9->CP9_DESPAR:="na contrata��o de institui��o brasileira incumbida regimental ou estatutariamente da pesquisa, do ensino ou do desenvolvimento institucional ou de institui��o dedicada � recupera��o social do preso, desde que a contratada detenha inquestion�vel reputa��o �tico-profissional e n�o tenha fins lucrativos" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="VIII" 
		CP9->CP9_DESPAR:="para a aquisi��o de componentes ou pe�as de origem nacional ou estrangeira necess�rios � manuten��o de equipamentos durante o per�odo de garantia t�cnica, junto ao fornecedor original desses equipamentos, quando tal condi��o de exclusividade for indispens�vel para a vig�ncia da garantia" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="IX" 
		CP9->CP9_DESPAR:="na contrata��o de associa��o de pessoas com defici�ncia f�sica, sem fins lucrativos e de comprovada idoneidade, para a presta��o de servi�os ou fornecimento de m�o de obra, desde que o pre�o contratado seja compat�vel com o praticado no mercado" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="X" 
		CP9->CP9_DESPAR:="na contrata��o de concession�rio, permission�rio ou autorizado para fornecimento ou suprimento de energia el�trica ou g�s natural e de outras prestadoras de servi�o p�blico, segundo as normas da legisla��o espec�fica, desde que o objeto do contrato tenha pertin�ncia com o servi�o p�blico" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XI" 
		CP9->CP9_DESPAR:="nas contrata��es entre empresas p�blicas ou sociedades de economia mista e suas respectivas subsidi�rias, para aquisi��o ou aliena��o de bens e presta��o ou obten��o de servi�os, desde que os pre�os sejam compat�veis com os praticados no mercado e que o objeto do contrato tenha rela��o com a atividade da contratada prevista em seu estatuto social" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XII" 
		CP9->CP9_DESPAR:="na contrata��o de coleta, processamento e comercializa��o de res�duos s�lidos urbanos recicl�veis ou reutiliz�veis, em �reas com sistema de coleta seletiva de lixo, efetuados por associa��es ou cooperativas formadas exclusivamente por pessoas f�sicas de baixa renda que tenham como ocupa��o econ�mica a coleta de materiais recicl�veis, com o uso de equipamentos compat�veis com as normas t�cnicas, ambientais e de sa�de p�blica" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XIII" 
		CP9->CP9_DESPAR:="para o fornecimento de bens e servi�os, produzidos ou prestados no Pa�s, que envolvam, cumulativamente, alta complexidade tecnol�gica e defesa nacional, mediante parecer de comiss�o especialmente designada pelo dirigente m�ximo da empresa p�blica ou da sociedade de economia mista" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XIV" 
		CP9->CP9_DESPAR:="nas contrata��es visando ao cumprimento do disposto nos arts. 3�, 4�, 5� e 20 da Lei no 10.973, de 2 de dezembro de 2004, observados os princ�pios gerais de contrata��o dela constantes" 
		MsUnLock()
														
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XV" 
		CP9->CP9_DESPAR:="em situa��es de emerg�ncia, quando caracterizada urg�ncia de atendimento de situa��o que possa ocasionar preju�zo ou comprometer a seguran�a de pessoas, obras, servi�os, equipamentos e outros bens, p�blicos ou particulares, e somente para os bens necess�rios ao atendimento da situa��o emergencial e para as parcelas de obras e servi�os que possam ser conclu�das no prazo m�ximo de 180 (cento e oitenta) dias consecutivos e ininterruptos, contado da ocorr�ncia da emerg�ncia, vedada a prorroga��o dos respectivos contratos, observado o disposto no � 2o" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XVI" 
		CP9->CP9_DESPAR:="na transfer�ncia de bens a �rg�os e entidades da administra��o p�blica, inclusive quando efetivada mediante permuta" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XVII" 
		CP9->CP9_DESPAR:="na doa��o de bens m�veis para fins e usos de interesse social, ap�s avalia��o de sua oportunidade e conveni�ncia socioecon�mica relativamente � escolha de outra forma de aliena��o" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XVIII" 
		CP9->CP9_DESPAR:="na compra e venda de a��es, de t�tulos de cr�dito e de d�vida e de bens que produzam ou comercializem" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="1�" 
		CP9->CP9_DESPAR:="Na hip�tese de nenhum dos licitantes aceitar a contrata��o nos termos do inciso VI do caput, a empresa p�blica e a sociedade de economia mista poder�o convocar os licitantes remanescentes, na ordem de classifica��o, para a celebra��o do contrato nas condi��es ofertadas por estes, desde que o respectivo valor seja igual ou inferior ao or�amento estimado para a contrata��o, inclusive quanto aos pre�os atualizados nos termos do instrumento convocat�rio" 
		MsUnLock()	

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="2�" 
		CP9->CP9_DESPAR:="A contrata��o direta com base no inciso XV do caput n�o dispensar� a responsabiliza��o de quem, por a��o ou omiss�o, tenha dado causa ao motivo ali descrito, inclusive no tocante ao disposto na Lei no 8.429, de 2 de junho de 1992" 
		MsUnLock()		

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="3�" 
		CP9->CP9_DESPAR:="Os valores estabelecidos nos incisos I e II do caput podem ser alterados, para refletir a varia��o de custos, por delibera��o do Conselho de Administra��o da empresa p�blica ou sociedade de economia mista, admitindo-se valores diferenciados para cada sociedade" 
		MsUnLock()
		
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="III" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="V" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="VI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="VII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="VIII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="IX" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="X" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XIII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XIV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
																				
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XVI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XVII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XVIII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="1�" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="2�" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="3�" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
	EndIf

	//Artigos, incisos e par�grados da lei 13.303 para o Artigo 29 (DISPENSA DE LICITACAO)
	If	CP8->(!DbSeek(xFilial("CP8")+"5"+"30"))		
		//-- Cabe�alho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="5"
		CP8->CP8_ARTIGO:="30"
		CP8->CP8_DESART:="Inexig�vel de Licita��o"
		MsUnLock()
		
		//-- Artigos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="30"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="aquisi��o de materiais, equipamentos ou g�neros que s� possam ser fornecidos por produtor, empresa ou representante comercial exclusivo" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="30"
		CP9->CP9_PARAG:="II" 
		cTexto	:= "contrata��o dos seguintes servi�os t�cnicos especializados, com profissionais ou empresas de not�ria especializa��o, vedada a inexigibilidade para servi�os de publicidade e divulga��o: " + CRLF
		cTexto	+= "a) estudos t�cnicos, planejamentos e projetos b�sicos ou executivos; " + CRLF
		cTexto	+= "b) pareceres, per�cias e avalia��es em geral; " + CRLF
		cTexto	+= "c) assessorias ou consultorias t�cnicas e auditorias financeiras ou tribut�rias; " + CRLF
		cTexto	+= "d) fiscaliza��o, supervis�o ou gerenciamento de obras ou servi�os; " + CRLF
		cTexto	+= "e) patroc�nio ou defesa de causas judiciais ou administrativas; " + CRLF
		cTexto	+= "f) treinamento e aperfei�oamento de pessoal; " + CRLF
		cTexto	+= "g) restaura��o de obras de arte e bens de valor hist�rico. " + CRLF
		
		CP9->CP9_DESPAR:= cTexto 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="30"
		CP9->CP9_PARAG:="1�" 
		CP9->CP9_DESPAR:="Considera-se de not�ria especializa��o o profissional ou a empresa cujo conceito no campo de sua especialidade, decorrente de desempenho anterior, estudos, experi�ncia, publica��es, organiza��o, aparelhamento, equipe t�cnica ou outros requisitos relacionados com suas atividades, permita inferir que o seu trabalho � essencial e indiscutivelmente o mais adequado � plena satisfa��o do objeto do contrato" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="30"
		CP9->CP9_PARAG:="2�" 
		CP9->CP9_DESPAR:="Na hip�tese do caput e em qualquer dos casos de dispensa, se comprovado, pelo �rg�o de controle externo, sobrepre�o ou superfaturamento, respondem solidariamente pelo dano causado quem houver decidido pela contrata��o direta e o fornecedor ou o prestador de servi�os" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="30"
		CP9->CP9_PARAG:="3�" 
		
		cTexto	:= "O processo de contrata��o direta ser� instru�do, no que couber, com os seguintes elementos: " + CRLF		
		cTexto	+= "I-caracteriza��o da situa��o emergencial ou calamitosa que justifique a dispensa, quando for o caso; " + CRLF
		cTexto	+= "II-raz�o da escolha do fornecedor ou do executante;  " + CRLF
		cTexto	+= "III-b) justificativa do pre�o." + CRLF
		CP9->CP9_DESPAR := cTexto 
		MsUnLock()
						
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="30"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="30"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="30"
		CPB->CPB_PARAG:="1�" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="30"
		CPB->CPB_PARAG:="2�" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="30"
		CPB->CPB_PARAG:="3�" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
	EndIf	 
	
	//-- ART. 81 - Da Altera��o dos Contratos - Lei 13.303 
	If  CP8->( !DbSeek(xFilial("CP8")+"5"+"81") )
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL := xFilial("CP8")
		CP8->CP8_LEI := "5"
		CP8->CP8_ARTIGO := "81"
		CP8->CP8_DESART := "Os contratos celebrados nos regimes previstos nos incisos I a V do art. 43 contar�o com cl�usula que estabele�a a possibilidade de altera��o, por acordo entre as partes, nos seguintes casos:"
		MsUnlock()
	
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "I"
		CP9->CP9_DESPAR := "quando houver modifica��o do projeto ou das especifica��es, para melhor adequa��o t�cnica aos seus objetivos;"		
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "II"
		CP9->CP9_DESPAR := "quando necess�ria a modifica��o do valor contratual em decorr�ncia de acr�scimo ou diminui��o quantitativa de seu objeto, nos limites permitidos por esta Lei;"
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "III"
		CP9->CP9_DESPAR := "quando conveniente a substitui��o da garantia de execu��o;"
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "IV"
		CP9->CP9_DESPAR	:= "quando necess�ria a modifica��o do regime de execu��o da obra ou servi�o, bem como do modo de fornecimento, em face de verifica��o t�cnica da inaplicabilidade dos termos contratuais origin�rios;"
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "V"
		CP9->CP9_DESPAR := "quando necess�ria a modifica��o da forma de pagamento, por imposi��o de circunst�ncias supervenientes, mantido o valor inicial atualizado, vedada a antecipa��o do pagamento, com rela��o ao cronograma financeiro fixado, sem a correspondente contrapresta��o de fornecimento de bens ou execu��o de obra ou servi�o;"
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "VI"
		CP9->CP9_DESPAR := "para restabelecer a rela��o que as partes pactuaram inicialmente entre os encargos do contratado e a retribui��o da administra��o para a justa remunera��o da obra, servi�o ou fornecimento, objetivando a manuten��o do equil�brio econ�mico-financeiro inicial do contrato, na hip�tese de sobrevirem fatos imprevis�veis, ou previs�veis por�m de consequ�ncias incalcul�veis, retardadores ou impeditivos da execu��o do ajustado, ou, ainda, em caso de for�a maior, caso fortuito ou fato do pr�ncipe, configurando �lea econ�mica extraordin�ria e extracontratual."
		MsUnlock()
	
	EndIf

	If	CP8->(!DbSeek(xFilial("CP8")+"5"+"32"))	

		RecLock("CP8",.T.)
		CP8->CP8_FILIAL := xFilial("CP8")
		CP8->CP8_LEI 	:= "5"
		CP8->CP8_ARTIGO := "32"
		CP8->CP8_DESART := "Nas licita��es e contratos de que trata esta Lei ser�o observadas as seguintes diretrizes:"
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI 	:= "5"
		CP9->CP9_ARTIGO := "32"
		CP9->CP9_PARAG 	:= "IV"
		CP9->CP9_DESPAR := "ado��o preferencial da modalidade de licita��o denominada preg�o, institu�da pela Lei n� 10.520, de 17 de julho de 2002 , para a aquisi��o de bens e servi�os comuns, assim considerados aqueles cujos padr�es de desempenho e qualidade possam ser objetivamente definidos pelo edital, por meio de especifica��es usuais no mercado;"
		MsUnlock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL	:= xFilial("CPB")
		CPB->CPB_LEI	:= "5"
		CPB->CPB_ARTIGO	:= "32"
		CPB->CPB_PARAG	:= "IV" 
		CPB->CPB_MODALI	:= "PG" 
		MsUnlock()

	EndIf
	
	End Transaction
	
	CP8->(DbGoTop())
	
EndIf
		
Return                       
//-------------------------------------------------------------------
/*/{Protheus.doc} GCP140PVld()
Fun��o executada na p�s valida��o do modelo 

@author matheus.raimundo
@since 09/06/2015
@version 1.0
@return lRet	
/*/
//-------------------------------------------------------------------
Function GCP140PVld(oModel)
Local oCP8Master	:= oModel:GetModel('CP8MASTER')
Local lRet 		:= .T.

If oModel:GetOperation()==MODEL_OPERATION_INSERT
CP8->(DbSetOrder(1))
If	CP8->(DbSeek(xFilial("CP8")+oCP8Master:GetValue('CP8_LEI')+oCP8Master:GetValue('CP8_ARTIGO')))
	lRet := .F.
	Help('', 1, 'JAGRAVADO')			     
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP140Rela()
Fun��o para inicializa��o do campo CPB_DESMOD

@author filipe.goncalves
@since 09/06/2015
@version 1.0
@return lRet	
/*/
//-------------------------------------------------------------------
Function GCP140Rela()
Local cCod		:= ""
Local oModel	:= FwModelActive()
Local oModCPB	:= oModel:GetModel("CPBDETAIL")
Local nL		:= oModCPB:GetLine()
	
If nL == 0 
	cCod := POSICIONE("SX5",1,XFILIAL("SX5")+"LF"+CPB->CPB_MODALI,"X5_DESCRI")
Else
	cCod := ""
EndIf

Return cCod
