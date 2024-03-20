data "template_file" "inventory" {
    template = "${file("../ansible/inventory.tpl")}"

    vars = {
        APIG = "${aws_instance.APIG.public_dns}"
        kafka = "${aws_instance.kafka.public_dns}"
    }
}

resource "null_resource" "update_inventory" {

    triggers = {
        template = "${data.template_file.inventory.rendered}"
    }

    provisioner "local-exec" {
        command = "echo '${data.template_file.inventory.rendered}' > ../ansible/hosts.ini"
    }
}