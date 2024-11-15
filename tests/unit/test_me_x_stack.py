import aws_cdk as core
import aws_cdk.assertions as assertions

from me_x.me_x_stack import MeXStack

# example tests. To run these tests, uncomment this file along with the example
# resource in me_x/me_x_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = MeXStack(app, "me-x")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
