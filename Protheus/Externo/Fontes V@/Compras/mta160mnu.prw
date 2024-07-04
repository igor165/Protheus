#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} u_mta160mnu()
    Ponto de Entrada localizado na An�lise de Cota��es na fun��o MenuDef(). 
    Permite adicionar bot�es ao menu.Os bot�es adcionais, devem ser carregados na vari�vel 
    aRotina, que conter� as op��es atuais e as novas op��es adicionadas.
    Adiciona a fun��o u_vacomr05 para o menu da rotna mata160.
/*/
user function mta160mnu()
    AAdd(aRotina, { "Exporta Excel", "u_vacomr05", 0 , 6, 0, .f.})
return nil